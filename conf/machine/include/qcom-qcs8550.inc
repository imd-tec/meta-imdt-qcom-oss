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

# Boot via systemd-boot (like imdt-6490-sbc). The BOOT.MXF UEFI does the FIT
# DTB selection, so u-boot is not part of the boot chain at all.
EFI_PROVIDER = "systemd-boot"
#Firmware binaries
MACHINE_ESSENTIAL_EXTRA_RRECOMMENDS += " \
    packagegroup-sm8550-hdk-firmware \
    packagegroup-sm8550-hdk-hexagon-dsp-binaries  \
    qairt-sdk-hexagon-v73 \
"
