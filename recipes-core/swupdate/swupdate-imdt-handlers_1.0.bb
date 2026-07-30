SUMMARY = "IMDT SWUpdate Lua handlers (A/B rootfs)"
DESCRIPTION = "Ships swupdate_handlers.lua in Lua's search path, providing \
the 'rootfs_ab' image handler: it identifies the active rootfs slot (from \
/proc/mounts, falling back to the kernel cmdline root= and then the U-Boot \
rootfs_part env when /proc/mounts shows /dev/root), refuses to write the \
mounted root, writes the bundled rootfs image to the inactive slot via the \
built-in raw handler and flips the U-Boot rootfs_part env var on success. \
Loaded by SWUpdate at startup, which requires CONFIG_HANDLER_IN_LUA \
(enabled via the swupdate bbappend)."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_MACHINE = "qcs8550"

DEPENDS = "lua"

SRC_URI = "file://swupdate_handlers.lua"

S = "${UNPACKDIR}"

inherit pkgconfig

do_install() {
    LUAVER=$(pkg-config --modversion lua | grep -o '^[0-9]\+\.[0-9]\+')
    install -D -m 0644 ${UNPACKDIR}/swupdate_handlers.lua \
        ${D}${libdir}/lua/$LUAVER/swupdate_handlers.lua
}

FILES:${PN} = "${libdir}/lua"

RDEPENDS:${PN} = "swupdate"
