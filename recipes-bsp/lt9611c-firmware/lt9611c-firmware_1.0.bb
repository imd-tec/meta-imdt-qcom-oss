SUMMARY = "Lontium LT9611UXD firmware for the DSI to HDMI adapter"
DESCRIPTION = "Dual port DSI firmware for the LT9611UXD on the IM-PCA-0055-01 \
adapter. The lt9611c driver flashes it at probe when the bridge has none."
SECTION = "kernel"
LICENSE = "CLOSED"

SRC_URI = "file://LT9611UXD_DSI_2Port_LaneSwap_V1.1.bin"

S = "${UNPACKDIR}"

inherit allarch

do_compile[noexec] = "1"

do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/Lontium
    install -m 0644 ${UNPACKDIR}/LT9611UXD_DSI_2Port_LaneSwap_V1.1.bin \
        ${D}${nonarch_base_libdir}/firmware/Lontium/lt9611c_fw.bin
}

FILES:${PN} = "${nonarch_base_libdir}/firmware/Lontium"
