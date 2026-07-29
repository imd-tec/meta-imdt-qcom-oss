-- SPDX-License-Identifier: MIT
-- IMDT QCS8550 SBC: A/B rootfs image handler for SWUpdate.
--
-- Registered as 'rootfs_ab' and referenced by the sw-description in the
-- qcom-minimal-image.swu bundle. Writes the bundled rootfs image to the
-- inactive slot (/dev/sda3 = A, /dev/sda4 = B) via the built-in 'raw'
-- handler, then flips the U-Boot 'rootfs_part' env var (and resets
-- bootcount / sets upgrade_available) on success, so a single .swu always
-- lands on the inactive slot without any -e selection.
--
-- The active slot comes from /proc/mounts, not from 'rootfs_part': the env
-- var can desync from what the kernel actually mounted, and acting on a
-- stale value would raw-write the live rootfs (corruption that only
-- surfaces on the next reboot).
--
-- Loaded at SWUpdate startup (CONFIG_HANDLER_IN_LUA); handlers cannot be
-- registered from sw-description embedded-scripts, hence this file.

local SLOT_DEV = { ['3'] = '/dev/sda3', ['4'] = '/dev/sda4' }
local OTHER_SLOT = { ['3'] = '4', ['4'] = '3' }

-- Where fstab mounts the FAT partition holding uboot.env; must agree with
-- /etc/fw_env.config (shipped by the libubootenv bbappend).
local ENV_MOUNT = '/media/env'

-- Device and mount options for a given mountpoint, from /proc/mounts.
local function mount_entry(target)
    local f = io.open('/proc/mounts')
    if not f then
        return nil
    end
    local dev, opts
    for line in f:lines() do
        local d, mp, _, o = line:match('^(%S+)%s+(%S+)%s+(%S+)%s+(%S+)')
        if mp == target then
            dev, opts = d, o
            break
        end
    end
    f:close()
    return dev, opts
end

-- The device mounted as /, or nil if it is not one of the slot partitions
-- (e.g. /dev/root from an unresolved PARTUUID= root=).
local function mounted_root()
    local dev = mount_entry('/')
    for slot, node in pairs(SLOT_DEV) do
        if dev == node then
            return node, slot
        end
    end
    return nil
end

-- fstab mounts the env partition 'nofail', so if it is missing the slot
-- flip would silently land on the rootfs where U-Boot never sees it.
local function bootenv_writable()
    local dev, opts = mount_entry(ENV_MOUNT)
    if not dev then
        swupdate.error('rootfs_ab: ' .. ENV_MOUNT .. ' is not mounted; the ' ..
                       'U-Boot env file is unreachable, refusing to update')
        return false
    end
    for opt in (opts or ''):gmatch('[^,]+') do
        if opt == 'ro' then
            swupdate.error(string.format('rootfs_ab: %s (%s) is mounted ' ..
                                         'read-only; refusing to update',
                                         ENV_MOUNT, dev))
            return false
        end
    end
    return true
end

-- Target slot = the one we are not running from. Returns nil on any
-- ambiguity, having logged why; the caller must abort rather than guess.
local function inactive_slot()
    local root_dev, active = mounted_root()
    local env = swupdate.get_bootenv('rootfs_part')

    if not active then
        swupdate.error('rootfs_ab: cannot identify the running slot from ' ..
                       '/proc/mounts; refusing to write')
        return nil
    end
    if env ~= active then
        -- Not fatal: /proc/mounts wins and the flip below repairs the env.
        swupdate.info(string.format('rootfs_ab: rootfs_part=%s disagrees with ' ..
                                    'mounted root %s (slot %s); trusting /proc/mounts',
                                    tostring(env), root_dev, active))
    end

    local new = OTHER_SLOT[active]
    return SLOT_DEV[new], new, root_dev
end

-- The bootenv flip must not become durable ahead of the slot it points at.
local function sync_disks()
    if os and os.execute then
        os.execute('sync')
    end
end

local function rootfs_ab(image)
    if not swupdate.handler['raw'] then
        swupdate.error('rootfs_ab: built-in raw handler not available')
        return 1
    end

    -- Checked before anything is written: an update whose bootenv flip
    -- cannot be persisted is worse than no update at all.
    if not bootenv_writable() then
        return 1
    end

    local target_dev, new_part, root_dev = inactive_slot()
    if not target_dev then
        return 1
    end
    -- Belt and braces: never write the device we are running from.
    if target_dev == root_dev then
        swupdate.error('rootfs_ab: refusing to write mounted root ' .. root_dev)
        return 1
    end

    swupdate.info(string.format('rootfs_ab: writing %s to inactive slot %s ' ..
                                '(running from %s)',
                                tostring(image.filename), target_dev, root_dev))

    -- Reuse the built-in raw handler; just point it at the inactive slot.
    image.device = target_dev
    local err, msg = swupdate.call_handler('raw', image)
    if err ~= 0 then
        swupdate.error(string.format('rootfs_ab: raw write failed: %s',
                                     tostring(msg)))
        return 1
    end

    sync_disks()

    swupdate.info('rootfs_ab: setting rootfs_part=' .. new_part)
    swupdate.set_bootenv('rootfs_part', new_part)
    swupdate.set_bootenv('bootcount', '0')
    swupdate.set_bootenv('upgrade_available', '1')
    return 0
end

swupdate.register_handler('rootfs_ab', rootfs_ab,
                          swupdate.HANDLER_MASK.IMAGE_HANDLER)
