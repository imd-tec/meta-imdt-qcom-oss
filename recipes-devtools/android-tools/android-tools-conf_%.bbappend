FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI:append = " file://adbd-retry.conf"

do_install:append() {
    # The UDC can show up after adbd's first five starts, so retry slowly.
    install -d ${D}${systemd_system_unitdir}/android-tools-adbd.service.d
    install -m 0644 ${UNPACKDIR}/adbd-retry.conf ${D}${systemd_system_unitdir}/android-tools-adbd.service.d/60-adbd-retry.conf
}

FILES:${PN}:append = " ${systemd_system_unitdir}/android-tools-adbd.service.d/60-adbd-retry.conf"
