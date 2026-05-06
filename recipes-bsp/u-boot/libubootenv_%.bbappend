FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# Ship /etc/fw_env.config alongside fw_printenv / fw_setenv. It points at
# /media/env/uboot.env (the FAT partition labelled UBOOT_ENV, mounted by
# the base-files bbappend) and the size matches CONFIG_ENV_SIZE.
SRC_URI:append:qcs8550 = " file://fw_env.config"

do_install:append:qcs8550() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${UNPACKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
}

# Bin package (RPROVIDES u-boot-fw-utils) is where fw_printenv lives, so
# pack the config with it.
FILES:${PN}-bin:append:qcs8550 = " ${sysconfdir}/fw_env.config"
