SUMMARY = "Check and update the A/B boot firmware against the OSTree deployment"
DESCRIPTION = "imdt-boot compares the boot firmware partitions with the \
manifest imdt-boot-firmware ships in each OSTree deployment, warns at boot \
when they differ, and can write the firmware to the other slot and switch \
to it."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=be497cfb223765dae07d1fa35204e4e2"

require imdt-boot.inc

SRC_URI += "file://imdt-boot.service"

inherit cargo cargo-update-recipe-crates systemd

# Regenerate after a SRCREV bump: bitbake -c update_crates imdt-boot
require ${BPN}-crates.inc

do_install:append() {
    install -D -m 0644 ${UNPACKDIR}/imdt-boot.service ${D}${systemd_system_unitdir}/imdt-boot.service
}

SYSTEMD_SERVICE:${PN} = "imdt-boot.service"

# ufs-utils sets bBootLunEn, the manifest and images come with the image.
RDEPENDS:${PN} = "ufs-utils imdt-boot-firmware"
