# imdt-8550-sbc SSC sensors: LSM6DSV on SSC SE0 (I3C), AK09918C and SHT40 on SE1.
# The stock SC8380 configs assert the ADSP registry, so ship kalama-derived
# IOT_HDK ones with the SBC pin/bus changes and a json.lst naming only those.
FILESEXTRAPATHS:prepend:imdt-8550-sbc := "${THISDIR}/${PN}:"
SRC_URI:append:imdt-8550-sbc = " file://config"

do_install:append:imdt-8550-sbc() {
    install -m 0644 ${UNPACKDIR}/config/* ${D}${sysconfdir}/sensors/config/
}
