FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# The 'rootfs_ab' Lua handler (shipped by swupdate-imdt-handlers as
# swupdate_handlers.lua) is loaded at SWUpdate startup, which requires
# CONFIG_HANDLER_IN_LUA — off in meta-swupdate's defconfig. Fragments
# ending in .cfg are merged on top of the defconfig by do_configure.
SRC_URI:append:qcs8550 = " file://handler-in-lua.cfg"
