SUMMARY = "Confirm a successful boot to U-Boot's automatic-rollback scheme"
DESCRIPTION = "Ships a systemd oneshot service that runs once the system \
reaches multi-user.target and clears the U-Boot 'bootcount' and \
'upgrade_available' env vars via fw_setenv. The SWUpdate rootfs_ab handler \
sets upgrade_available=1 / bootcount=0 when installing to the inactive \
slot; if this service never runs, U-Boot's bootcount limit triggers an \
automatic rollback to the previous slot."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_MACHINE = "qcs8550"

SRC_URI = " \
    file://mark-boot-successful \
    file://mark-boot-successful.service \
"

S = "${UNPACKDIR}"

inherit systemd

SYSTEMD_SERVICE:${PN} = "mark-boot-successful.service"

do_install() {
    install -D -m 0755 ${UNPACKDIR}/mark-boot-successful \
        ${D}${sbindir}/mark-boot-successful
    install -D -m 0644 ${UNPACKDIR}/mark-boot-successful.service \
        ${D}${systemd_system_unitdir}/mark-boot-successful.service
}

# fw_printenv / fw_setenv plus the /etc/fw_env.config shipped by the
# libubootenv bbappend.
RDEPENDS:${PN} = "libubootenv-bin"
