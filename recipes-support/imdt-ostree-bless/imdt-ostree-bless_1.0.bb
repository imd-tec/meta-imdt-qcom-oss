SUMMARY = "Clear the systemd-boot BLS boot counter for the running OSTree deployment"
DESCRIPTION = "No EFI variable runtime here, so systemd-bless-boot can't clear \
OSTree's BLS boot counter. This marks the running deployment good from userspace."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_MACHINE = "qcs8550"

SRC_URI = " \
    file://imdt-ostree-bless \
    file://imdt-ostree-bless.service \
"
S = "${UNPACKDIR}"

inherit systemd

do_install() {
    install -D -m 0755 ${UNPACKDIR}/imdt-ostree-bless ${D}${sbindir}/imdt-ostree-bless
    install -D -m 0644 ${UNPACKDIR}/imdt-ostree-bless.service \
        ${D}${systemd_system_unitdir}/imdt-ostree-bless.service
}

SYSTEMD_SERVICE:${PN} = "imdt-ostree-bless.service"

FILES:${PN} = "${sbindir}/imdt-ostree-bless ${systemd_system_unitdir}/imdt-ostree-bless.service"
