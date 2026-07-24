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

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:append = " file://sdiouartiw416_combo_v0.bin.lf-6.1.22_2.0.0"

do_install:append() {
    # Install NXP Connectivity IW416 Wi-Fi/BT combo firmware
    install -d ${D}${nonarch_base_libdir}/firmware/mrvl
    install -m 0644 ${WORKDIR}/sdiouartiw416_combo_v0.bin.lf-6.1.22_2.0.0 \
        ${D}${nonarch_base_libdir}/firmware/mrvl/sdiouartiw416_combo_v0.bin
}

PACKAGES =+ "${PN}-iw416-sdio"
FILES:${PN}-iw416-sdio = "${nonarch_base_libdir}/firmware/mrvl/sdiouartiw416_combo_v0.bin"
