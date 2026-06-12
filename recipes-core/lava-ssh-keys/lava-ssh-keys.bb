SUMMARY = "Install LAVA dispatcher SSH public key for automated testing"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://lava-dut-key.pub"

S = "${UNPACKDIR}"

do_install() {
    install -d -m 0700 ${D}${ROOT_HOME}/.ssh
    install -m 0600 ${UNPACKDIR}/lava-dut-key.pub ${D}${ROOT_HOME}/.ssh/authorized_keys
}

FILES:${PN} = "${ROOT_HOME}/.ssh/authorized_keys"
