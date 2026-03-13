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
UBOOT_CONFIG = "qcs8550-hdk"
UBOOT_CONFIG[qcs8550-hdk] = "qcom_defconfig"
BOARD_MBN_HEADER[qcs8550-hdk] = "v7" 
#Use limine since it supports booting a kernel Image + DTB without having to use UKI which doesn't work
EFI_PROVIDER = "limine"
