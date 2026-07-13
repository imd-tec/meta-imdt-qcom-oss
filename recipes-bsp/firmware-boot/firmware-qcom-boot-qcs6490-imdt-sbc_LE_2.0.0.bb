FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DESCRIPTION = "QCOM Boot binaries for IMDT QCS6490 SBC"
LICENSE = "CLOSED"

# Common include
require recipes-bsp/firmware-boot/firmware-qcom-boot-common.inc

SRC_URI = " \
    file://imdt-6490-sbc-fw_LE_2_0_0.zip;name=bootbinaries \
"
SRC_URI[bootbinaries.sha256sum] = "4ba35c7023cba492583f45c0475cc2757f4127801af9dfbd12e5c36906775f5c"
SRCREV = "308ca2ecbbe77658f5633a328c3f1cc6bb93d47e"

BOOTBINARIES = "QCM6490_bootbinaries"
