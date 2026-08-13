# Configurations and variables for QCS8550 SoC family.

SOC_FAMILY = "qcs8550"
require conf/machine/include/qcom-base.inc
require conf/machine/include/qcom-common.inc
require conf/machine/include/imdt-common.inc

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
# Allow firmware-nxp-wifi to be used on our board
MACHINEOVERRIDES:append = ":imx-generic-bsp"

UBOOT_CONFIG_DEFAULT = "qcs8550-hdk"
UBOOT_CONFIG = "sm8550"
UBOOT_CONFIG[sm8550] = "qcom_defconfig"
BOARD_MBN_HEADER[sm8550] = "v7"
# Boot via systemd-boot (like imdt-6490-sbc). The BOOT.MXF UEFI does FIT DTB
# selection, so u-boot no longer runs as the UEFI app (kept only as provider).
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-concept"
EFI_PROVIDER = "systemd-boot"
#Firmware binaries
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += " \
    packagegroup-sm8550-hdk-firmware \
    packagegroup-sm8550-hdk-hexagon-dsp-binaries  \
    qairt-sdk-hexagon-v73 \
"
