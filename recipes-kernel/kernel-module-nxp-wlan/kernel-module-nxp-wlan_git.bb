SUMMARY = "NXP Wi-Fi driver (moal/mlan) for the IW610 on the QCS6490 SBC"
DESCRIPTION = "Out-of-tree NXP Wi-Fi driver. The QCS6490 SBC's Murata \
LBES0ZZ2LL module is an NXP IW610, which no in-kernel driver supports yet."
HOMEPAGE = "https://github.com/nxp-imx/mwifiex"
SECTION = "kernel"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://LICENSE;md5=ab04ac0f249af12befccb94447c08b77"

# Based on meta-freescale's kernel-module-nxp-wlan_git.bb.
SRC_URI = " \
    git://github.com/nxp-imx/mwifiex.git;protocol=https;branch=${SRCBRANCH} \
    file://0001-mlinux-moal_main-fix-device-wakeup-capability.patch \
    file://0002-mlinux-Build-against-kernel-7.2.patch \
"
SRCBRANCH = "lf-6.18.2_1.0.0"
SRCREV = "a5fe4e194bf99315e349d81d77d6dfacec70757a"

inherit module

EXTRA_OEMAKE = "KERNELDIR=${STAGING_KERNEL_BUILDDIR} -C ${STAGING_KERNEL_BUILDDIR} M=${S}"

KERNEL_MODULE_AUTOLOAD += "moal"
KERNEL_MODULE_PROBECONF += "moal"
module_conf_moal = "options moal mod_para=nxp/wifi_mod_para.conf"

RRECOMMENDS:${PN} += "firmware-nxp-iw610"

COMPATIBLE_MACHINE = "imdt-6490-sbc"
