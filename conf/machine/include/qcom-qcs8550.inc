# Configurations and variables for QCS8550 SoC family.

SOC_FAMILY = "qcs8550"
require conf/machine/include/qcom-base.inc
require conf/machine/include/qcom-common.inc

DEFAULTTUNE = "armv8-2a-crypto"
require conf/machine/include/arm/arch-armv8-2a.inc


MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += " \
    packagegroup-qcom-boot-essential \
    packagegroup-machine-essential-qcom-qcs8550-soc \
    abl2esp \
"

MACHINE_EXTRA_RRECOMMENDS += " \
    packagegroup-qcom-boot-additional \
"


UBOOT_CONFIG_DEFAULT = "qcs8550-hdk"
UBOOT_CONFIG = "sm8550"
UBOOT_CONFIG[sm8550] = "qcom_defconfig"
BOARD_MBN_HEADER[sm8550] = "v7" 
#Use u-boot as an UEFI App so that Device tree fixups can be applied
EFI_PROVIDER = "u-boot-qcom"
# U-boot extlinux config file settings
UBOOT_EXTLINUX = "1"
UBOOT_EXTLINUX_ROOT = "root=${QCOM_BOOTIMG_ROOTFS}"
UBOOT_EXTLINUX_KERNEL_ARGS = "earlycon loglevel=7"
# Use default console
UBOOT_EXTLINUX_CONSOLE = ""
EFI_DTBS_FOLDER = "/dtb/qcom/"
UBOOT_EXTLINUX_FDT = "${EFI_DTBS_FOLDER}/${QCOM_DTB_DEFAULT}"
#Firmware binaries
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += " \
    packagegroup-sm8550-hdk-firmware \
    packagegroup-sm8550-hdk-hexagon-dsp-binaries  \
    qairt-sdk-hexagon-v73 \
"