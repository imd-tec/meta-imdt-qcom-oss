# imdt-8550-sbc SSC sensors: LSM6DSV on SSC SE0 (I3C), AK09918C and SHT40 on SE1.
# Kalama-derived IOT_HDK configs with the SBC pin/bus changes and a json.lst
# naming only those. sscrpcd stays off: while it runs the ADSP sns_registry
# asserts and crash-loops, even with only these configs.
FILESEXTRAPATHS:prepend:imdt-8550-sbc := "${THISDIR}/${PN}:"
SRC_URI:append:imdt-8550-sbc = " file://config file://imdt-sscrpcd-off.conf"

do_install:append:imdt-8550-sbc() {
    install -m 0644 ${UNPACKDIR}/config/* ${D}${sysconfdir}/sensors/config/
    install -Dm 0644 ${UNPACKDIR}/imdt-sscrpcd-off.conf \
        ${D}${systemd_system_unitdir}/sscrpcd.service.d/imdt-sscrpcd-off.conf
}

FILES:${PN}:append:imdt-8550-sbc = " ${systemd_system_unitdir}/sscrpcd.service.d"
