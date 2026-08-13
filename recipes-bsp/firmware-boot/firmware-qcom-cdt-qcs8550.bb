# IMDT CDT so UEFI FIT selection matches imdt,qcs8550-sbc (board-id 0x20, oem-id 1).
# One per board revision (rev3/rev5), differing only in the revision byte 0x16.
require recipes-bsp/firmware-boot/firmware-qcom-cdt-common.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI = " \
    file://cdt_imdt_8550_sbc_rev3.bin \
    file://cdt_imdt_8550_sbc_rev5.bin \
"

QCOM_CDT_SUBDIR = "qcs8550"
