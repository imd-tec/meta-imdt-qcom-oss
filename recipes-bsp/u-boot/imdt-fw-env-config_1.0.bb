SUMMARY = "fw_env.config for libubootenv on the IMDT QCS8550 SBC"
DESCRIPTION = "Installs /etc/fw_env.config so fw_printenv/fw_setenv \
(from u-boot-fw-utils / libubootenv) can locate the U-Boot environment \
file on the FAT partition labelled 'env' (mounted at /media/env)."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_MACHINE = "qcs8550"

SRC_URI = "file://fw_env.config"

S = "${UNPACKDIR}"

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${UNPACKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}

FILES:${PN} = "${sysconfdir}/fw_env.config"

# fw_env.config is only useful with the tools that consume it. The
# /media/env mount point it references is set up via the base-files
# bbappend in this layer.
RDEPENDS:${PN} = "u-boot-fw-utils"
