DESCRIPTION = "QCOM Boot binaries for Qualcomm QCS6490 platform (Built by IMDT Ltd)"
LICENSE = "CLOSED"
require recipes-bsp/firmware-boot/firmware-qcom-boot-common.inc
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = " \
    file://imdt-6490-sbc-fw_LE_2_0_0.zip;name=bootbinaries \
"
SRC_URI[bootbinaries.sha256sum] = "fa708a40b9fcce134c5743273624fc0e7633e277a7b38840963defb06840e0b9"
BOOTBINARIES = "QCM6490_bootbinaries"
