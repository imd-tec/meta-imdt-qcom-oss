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
# PC-like strategy: ship kernel + DTBs in /boot
MACHINE_ESSENTIAL_EXTRA_RDEPENDS += " \
    kernel-image \
    kernel-devicetree \
    kernel-modules \
"

MACHINE_EXTRA_RRECOMMENDS += " \
    packagegroup-qcom-boot-additional \
    u-boot-fw-utils \
"


UBOOT_CONFIG_DEFAULT = "qcs8550-hdk"
UBOOT_CONFIG = "sm8550"
UBOOT_CONFIG[sm8550] = "qcom_defconfig"
BOARD_MBN_HEADER[sm8550] = "v7" 
# Build u-boot initial env binary
UBOOT_INITIAL_ENV = "u-boot-initial-env"
UBOOT_INITIAL_ENV_BINARY_SIZE = "0x2000"
UBOOT_INITIAL_ENV_BINARY = '1'
# FAT32 partition image wrapping the binary env as /uboot.env.
UBOOT_ENV_IMG_NAME       = "uboot_env.img"
UBOOT_ENV_FILENAME       = "uboot.env"
UBOOT_ENV_IMG_LABEL      = "UBOOT_ENV"
UBOOT_ENV_IMG_SIZE_MIB   = "64"
UBOOT_ENV_IMG_SIZE_BYTES = "${@int(d.getVar('UBOOT_ENV_IMG_SIZE_MIB')) * 1024 * 1024}"
# UFS wants 4K logical block size, so use that for the FAT32 partition as well.
UBOOT_FAT32_LOGICAL_SIZE = "4096"
#Use u-boot as an UEFI App so that Device tree fixups can be applied.
#This is only supported in the concept u-boot fork, so prefer that over
#meta-qcom's u-boot-qcom for the whole SoC family.
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-concept"
EFI_PROVIDER = "u-boot-concept"
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
