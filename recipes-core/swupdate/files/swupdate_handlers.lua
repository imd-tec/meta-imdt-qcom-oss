-- SPDX-License-Identifier: MIT
-- IMDT QCS8550 SBC: A/B rootfs image handler for SWUpdate.
--
-- Registered as 'rootfs_ab' and referenced by the sw-description in the
-- qcom-console-image.swu bundle. Reads the U-Boot 'rootfs_part' env var
-- (3 -> /dev/sda3 active, 4 -> /dev/sda4 active), delegates the write of
-- the bundled rootfs image to the built-in 'raw' handler pointed at the
-- inactive slot, then flips 'rootfs_part' (and resets bootcount / sets
-- upgrade_available) on success. A single .swu therefore always lands on
-- the inactive slot, whether installed via the web UI, the IPC socket or
-- the CLI, without any -e selection.
--
-- Loaded at SWUpdate startup (CONFIG_HANDLER_IN_LUA); handlers cannot be
-- registered from sw-description embedded-scripts, hence this file.

local function inactive_slot()
    local current = swupdate.get_bootenv('rootfs_part')
    if current == '4' then
        return '/dev/sda3', '3'
    end
    -- Treat unset/unexpected values as slot A (partition 3) active.
    return '/dev/sda4', '4'
end

local function rootfs_ab(image)
    if not swupdate.handler['raw'] then
        swupdate.error('rootfs_ab: built-in raw handler not available')
        return 1
    end

    local target_dev, new_part = inactive_slot()
    swupdate.info(string.format('rootfs_ab: writing %s to inactive slot %s',
                                tostring(image.filename), target_dev))

    -- Reuse the built-in raw handler; just point it at the inactive slot.
    image.device = target_dev
    local err, msg = swupdate.call_handler('raw', image)
    if err ~= 0 then
        swupdate.error(string.format('rootfs_ab: raw write failed: %s',
                                     tostring(msg)))
        return 1
    end

    swupdate.info('rootfs_ab: setting rootfs_part=' .. new_part)
    swupdate.set_bootenv('rootfs_part', new_part)
    swupdate.set_bootenv('bootcount', '0')
    swupdate.set_bootenv('upgrade_available', '1')
    return 0
end

swupdate.register_handler('rootfs_ab', rootfs_ab,
                          swupdate.HANDLER_MASK.IMAGE_HANDLER)
