#
# Copyright (c) 2026 IMD Technologies
#
# Ship the NXP IW416 Wi-Fi/BT combo firmware for the SDIO WLAN module.
#
# The IW416 SDIO-UART combo image is NOT part of upstream linux-firmware
# (which only ships the BT-only nxp/uartiw416_bt_v0.bin); it is released by
# NXP as part of their imx-firmware distribution. This file was taken
# verbatim from the NXP imx-firmware git tag lf-6.1.22_2.0.0, path
# nxp/FwImage_IW416_SD/sdiouartiw416_combo_v0.bin
# (md5 64d51a3da2513bf661ec02be07ddca0c).
#
# The in-tree mwifiex driver (CONFIG_MWIFIEX_SDIO) requests this image under
# the "mrvl/" prefix (SD8978_SDIOUART_FW_NAME = "mrvl/sdiouartiw416_combo_v0.bin"),
# so it must be installed there for the WLAN chip to come up.
#
# Also ship the Cypress CYPD6125 USB-PD controller firmware images.

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:append = " file://sdiouartiw416_combo_v0.bin.lf-6.1.22_2.0.0"
SRC_URI:append = " file://CYPD6125-40LQXI_notebook_1.cyacd"
SRC_URI:append = " file://CYPD6125-40LQXI_notebook_2.cyacd"

# WCN7850 board data from linux-firmware 575bbe3f8356. The 20260916 release
# lacks the qmi-board-id=255 entry that generic M.2 Key-E cards report.
WCN7850_BDF_REV = "575bbe3f83565d18caa73e9b9458f754dd286f48"
SRC_URI:append = " https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/ath12k/WCN7850/hw2.0/board-2.bin?id=${WCN7850_BDF_REV};downloadfilename=wcn7850-board-2-${WCN7850_BDF_REV}.bin;name=wcn7850-bdf"
SRC_URI[wcn7850-bdf.sha256sum] = "6a98237c743d864773a547e81e23f0c6dc721dcd7331926bee7381e2152e00fd"

do_install:append() {
    # Install NXP Connectivity IW416 Wi-Fi/BT combo firmware
    install -d ${D}${nonarch_base_libdir}/firmware/mrvl
    install -m 0644 ${UNPACKDIR}/sdiouartiw416_combo_v0.bin.lf-6.1.22_2.0.0 \
        ${D}${nonarch_base_libdir}/firmware/mrvl/sdiouartiw416_combo_v0.bin

    # Replace the WCN7850 board data with the newer upstream file
    rm -f ${D}${firmwaredir}/ath12k/WCN7850/hw2.0/board-2.bin
    install -m 0644 ${UNPACKDIR}/wcn7850-board-2-${WCN7850_BDF_REV}.bin \
        ${D}${firmwaredir}/ath12k/WCN7850/hw2.0/board-2.bin

    # Install CYPD Firmware
    install -d ${D}${nonarch_base_libdir}/firmware
    install -m 0644 ${UNPACKDIR}/CYPD6125-40LQXI_notebook_1.cyacd ${D}${nonarch_base_libdir}/firmware/ccg_secondary.cyacd
    install -m 0644 ${UNPACKDIR}/CYPD6125-40LQXI_notebook_2.cyacd ${D}${nonarch_base_libdir}/firmware/ccg_primary.cyacd
}

PACKAGES =+ "${PN}-iw416-sdio"
FILES:${PN}-iw416-sdio = "${nonarch_base_libdir}/firmware/mrvl/sdiouartiw416_combo_v0.bin"

PACKAGES =+ "linux-firmware-cypd6125"
PROVIDES =+ "linux-firmware-cypd6125"

FILES:linux-firmware-cypd6125   = "${nonarch_base_libdir}/firmware/ccg_secondary.cyacd \
                                   ${nonarch_base_libdir}/firmware/ccg_primary.cyacd \
"
