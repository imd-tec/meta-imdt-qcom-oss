SUMMARY = "Install LAVA dispatcher SSH public key for automated testing"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "file://lava-dut-key.pub \
           file://10-lava-authorized-keys.conf \
"

S = "${UNPACKDIR}"

# Not ${ROOT_HOME}/.ssh: that is /var, which no OSTree deployment populates.
do_install() {
    install -D -m 0644 ${UNPACKDIR}/lava-dut-key.pub \
        ${D}${sysconfdir}/ssh/authorized_keys.d/root
    install -D -m 0644 ${UNPACKDIR}/10-lava-authorized-keys.conf \
        ${D}${sysconfdir}/ssh/sshd_config.d/10-lava-authorized-keys.conf
}

FILES:${PN} = "${sysconfdir}/ssh/authorized_keys.d/root \
               ${sysconfdir}/ssh/sshd_config.d/10-lava-authorized-keys.conf \
"
