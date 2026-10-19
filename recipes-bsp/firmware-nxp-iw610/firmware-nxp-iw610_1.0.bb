SUMMARY = "NXP IW610 Wi-Fi and Bluetooth firmware"
DESCRIPTION = "Firmware and driver configuration for the NXP IW610 on the \
QCS6490 SBC's Murata LBES0ZZ2LL module. linux-firmware does not ship it yet."
HOMEPAGE = "https://github.com/nxp-imx/imx-firmware"
SECTION = "kernel"
LICENSE = "LicenseRef-Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=bc649096ad3928ec06a8713b8d787eac"
NO_GENERIC_LICENSE[LicenseRef-Proprietary] = "LICENSE.txt"

SRC_URI = "git://github.com/nxp-imx/imx-firmware.git;protocol=https;branch=${SRCBRANCH}"
SRCBRANCH = "lf-6.18.2_1.0.0"
SRCREV = "d7e4bb37b45bbf93faf888e0ca6763a29e28054a"

inherit allarch

do_compile[noexec] = "1"

do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/nxp
    install -m 0644 ${S}/FwImage_IW610_SD/*.bin.se ${D}${nonarch_base_libdir}/firmware/nxp/
    install -m 0644 ${S}/wifi_mod_para.conf ${D}${nonarch_base_libdir}/firmware/nxp/
}

FILES:${PN} = "${nonarch_base_libdir}/firmware/nxp"
