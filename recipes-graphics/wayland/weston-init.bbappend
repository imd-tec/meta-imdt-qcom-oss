FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://wait-for-drm.conf"

do_install:append() {
    install -D -m 0644 ${UNPACKDIR}/wait-for-drm.conf \
        ${D}${systemd_system_unitdir}/weston.service.d/wait-for-drm.conf
}

FILES:${PN} += "${systemd_system_unitdir}/weston.service.d/wait-for-drm.conf"
