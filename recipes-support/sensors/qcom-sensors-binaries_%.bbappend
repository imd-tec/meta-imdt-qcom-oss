# imdt-8550-sbc SSC sensors: LSM6DSV on SSC SE0 (I3C), AK09918C and SHT40 on SE1.
# Ship only the kalama-derived IOT_HDK configs with the SBC pin/bus changes.
# The ADSP registry reads every file in the dir, so drop the stock ones.
# The ADSP opens /vendor/etc/sensors over FastRPC, so link it to /etc/sensors.
FILESEXTRAPATHS:prepend:imdt-8550-sbc := "${THISDIR}/${PN}:"
SRC_URI:append:imdt-8550-sbc = " file://config"

do_install:append:imdt-8550-sbc() {
    rm -f ${D}${sysconfdir}/sensors/config/*
    install -m 0644 ${UNPACKDIR}/config/* ${D}${sysconfdir}/sensors/config/
    install -d ${D}/vendor/etc
    ln -sfn ${sysconfdir}/sensors ${D}/vendor/etc/sensors
}

FILES:${PN}:append:imdt-8550-sbc = " /vendor/etc/sensors"
