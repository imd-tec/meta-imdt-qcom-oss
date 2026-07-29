FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DESCRIPTION = "QCOM Boot binaries for IMDT QCS6490 SBC"
LICENSE = "CLOSED"

# Common include
require recipes-bsp/firmware-boot/firmware-qcom-boot-common.inc

SRC_URI = " \
    file://imdt-6490-sbc-fw_LE_2_0_0.zip;name=bootbinaries \
"
SRC_URI[bootbinaries.sha256sum] = "be07f1828c4faa876e4fd342bc743c8da249874d8f9fd57d1be76f2459be36c5"
SRCREV = "308ca2ecbbe77658f5633a328c3f1cc6bb93d47e"

BOOTBINARIES = "QCM6490_bootbinaries"
