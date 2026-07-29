-- SPDX-License-Identifier: MIT
-- IMDT QCS8550 SBC: A/B rootfs image handler for SWUpdate.
--
-- Registered as 'rootfs_ab' and referenced by the sw-description in the
-- qcom-minimal-image.swu bundle. Works out which of /dev/sda3 (slot A) and
-- /dev/sda4 (slot B) is *inactive*, zeroes it, delegates the write of the
-- bundled rootfs image to the built-in 'raw' handler pointed at that slot,
-- then flips the U-Boot 'rootfs_part' env var (and resets bootcount / sets
-- upgrade_available) on success. A single .swu therefore always lands on
-- the inactive slot, whether installed via the web UI, the IPC socket or
-- the CLI, without any -e selection.
--
-- The active slot is taken from /proc/mounts rather than from
-- 'rootfs_part': the env var is what U-Boot *intends* to boot, and it can
-- desync from what the kernel actually mounted (a reset or relocated
-- U-Boot env — e.g. after the UEFI binary on the ESP is replaced — leaves
-- it stale or unset while the board keeps booting the other slot). Acting
-- on a stale value means raw-writing the live, mounted rootfs: the running
-- system limps along on page cache and the corruption only surfaces after
-- the next reboot. The write is refused outright if the target cannot be
-- proven to differ from the mounted root.
--
-- Loaded at SWUpdate startup (CONFIG_HANDLER_IN_LUA); handlers cannot be
-- registered from sw-description embedded-scripts, hence this file.

local SLOT_DEV = { ['3'] = '/dev/sda3', ['4'] = '/dev/sda4' }
local OTHER_SLOT = { ['3'] = '4', ['4'] = '3' }

-- Written in 4 MiB chunks; one shared buffer, allocated once.
local WIPE_CHUNK = 4 * 1024 * 1024
local WIPE_ZEROS = string.rep('\0', WIPE_CHUNK)

-- The device the kernel actually has mounted as /. Returns nil if it is
-- not one of the two slot partitions (e.g. /dev/root with a PARTUUID=
-- root= that the kernel did not resolve to a node), which the caller
-- treats as "cannot determine".
local function mounted_root()
    local f = io.open('/proc/mounts')
    if not f then
        return nil
    end
    local dev
    for line in f:lines() do
        local d, mp = line:match('^(%S+)%s+(%S+)')
        if mp == '/' then
            dev = d
            break
        end
    end
    f:close()
    for slot, node in pairs(SLOT_DEV) do
        if dev == node then
            return node, slot
        end
    end
    return nil
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
        -- Not fatal — /proc/mounts wins — but it means the env is stale,
        -- so the flip below is also repairing rootfs_part.
        swupdate.info(string.format('rootfs_ab: rootfs_part=%s disagrees with ' ..
                                    'mounted root %s (slot %s); trusting /proc/mounts',
                                    tostring(env), root_dev, active))
    end

    local new = OTHER_SLOT[active]
    return SLOT_DEV[new], new, root_dev
end

-- Partition size in bytes. /sys/class/block/<part>/size is always in
-- 512-byte units regardless of the device's logical block size.
local function partition_bytes(dev)
    local name = dev:match('([^/]+)$')
    local f = name and io.open('/sys/class/block/' .. name .. '/size')
    if not f then
        return nil
    end
    local sectors = tonumber(f:read('*l'))
    f:close()
    return sectors and sectors * 512
end

-- Zero the whole partition before the image lands on it. The raw write
-- only covers as many bytes as the ext4 image contains, which is sized
-- from the rootfs and is smaller than the slot; without this, everything
-- past the image end keeps the previous install's bytes, including its
-- backup superblocks (an e2fsck that ever falls back to one would find a
-- stale filesystem geometry).
local function zero_partition(dev)
    local size = partition_bytes(dev)
    if not size then
        swupdate.error('rootfs_ab: cannot read size of ' .. dev)
        return false
    end

    local f, err = io.open(dev, 'wb')
    if not f then
        swupdate.error(string.format('rootfs_ab: cannot open %s: %s',
                                     dev, tostring(err)))
        return false
    end
    f:setvbuf('no')

    local written = 0
    while written < size do
        local remaining = size - written
        local n = remaining < WIPE_CHUNK and remaining or WIPE_CHUNK
        local ok, werr = f:write(n == WIPE_CHUNK and WIPE_ZEROS
                                                 or WIPE_ZEROS:sub(1, n))
        if not ok then
            f:close()
            swupdate.error(string.format(
                'rootfs_ab: zeroing %s failed at %d/%d bytes: %s',
                dev, written, size, tostring(werr)))
            return false
        end
        written = written + n
    end
    f:close()

    -- math.floor, not '//': the integer-division operator is Lua 5.3+ and
    -- the Lua version here follows whatever meta-oe ships.
    swupdate.info(string.format('rootfs_ab: zeroed %s (%d MiB)',
                                dev, math.floor(size / (1024 * 1024))))
    return true
end

-- Flush the block writes to the device. The bootenv flip must not become
-- durable ahead of the slot it points at; a graceful reboot syncs anyway,
-- but a power loss in the window between the two would otherwise leave
-- U-Boot booting a partially-written rootfs.
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

    if not zero_partition(target_dev) then
        return 1
    end

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
