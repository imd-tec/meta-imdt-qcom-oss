DESCRIPTION = "QCOM Boot binaries for Qualcomm QCS6490 platform (Built by IMDT Ltd)"
LICENSE = "CLOSED"
require recipes-bsp/firmware-boot/firmware-qcom-boot-common.inc
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = " \
    file://imdt-6490-sbc-fw_LE_2_0_0.zip;name=bootbinaries \
"
SRC_URI[bootbinaries.sha256sum] = "4ba35c7023cba492583f45c0475cc2757f4127801af9dfbd12e5c36906775f5c"
BOOTBINARIES = "QCM6490_bootbinaries"
