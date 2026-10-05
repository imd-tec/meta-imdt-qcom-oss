# weston.service needs /home/weston (WorkingDirectory) to exist, but on our
# OSTree images /home is a symlink into /var, which OSTree resets to empty on
# every deployment - so the directory weston-init's do_install creates never
# actually ships. Recreate it at boot via tmpfiles.d instead. See
# docs/remote-desktop.md and the weston-unaffected-by-stop LAVA test.
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += "file://weston-home-tmpfiles.conf"

do_install:append() {
    install -d ${D}${nonarch_libdir}/tmpfiles.d
    install -m 0644 ${UNPACKDIR}/weston-home-tmpfiles.conf \
        ${D}${nonarch_libdir}/tmpfiles.d/weston-home.conf
}

FILES:${PN} += "${nonarch_libdir}/tmpfiles.d/weston-home.conf"
