SUMMARY = "Scripts for configuring cameras on the IMDT Qualcomm SBC"
DESCRIPTION = "Bash scripts for configuring media-ctl pipelines \
using the camss driver on IMDT Qualcomm platforms."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://qcs8550-csi0-ar1335.sh"

S = "${UNPACKDIR}"

do_install() {
    install -d ${D}/opt/imdt/camss
    install -m 0755 ${S}/qcs8550-csi0-ar1335.sh ${D}/opt/imdt/camss/
}

FILES:${PN} += "/opt/imdt/camss"
