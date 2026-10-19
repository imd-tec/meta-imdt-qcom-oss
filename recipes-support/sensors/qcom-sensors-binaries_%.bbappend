# imdt-8550-sbc has no ADSP sensors, and the shipped SC8380 sensor configs make
# the ADSP sensors registry assert, so the ADSP crash-loops while sscrpcd runs.
# The package stays installed, as camx-kodiak depends on it.
FILESEXTRAPATHS:prepend:imdt-8550-sbc := "${THISDIR}/${PN}:"
SRC_URI:append:imdt-8550-sbc = " file://imdt-sscrpcd-off.conf"

do_install:append:imdt-8550-sbc() {
    install -Dm 0644 ${UNPACKDIR}/imdt-sscrpcd-off.conf \
        ${D}${systemd_system_unitdir}/sscrpcd.service.d/imdt-sscrpcd-off.conf
}

FILES:${PN}:append:imdt-8550-sbc = " ${systemd_system_unitdir}/sscrpcd.service.d"
