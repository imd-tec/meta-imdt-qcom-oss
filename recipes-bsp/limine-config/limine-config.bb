SUMMARY = "Limine Bootloader Configuration"
DESCRIPTION = "This recipe provides the configuration file for the Limine Bootloader, which is used to boot Qualcomm boards instead of systemd-boot"
LICENSE = "CLOSED"
SRC_URI = "file://limine.conf"

inherit deploy

S = "${UNPACKDIR}"

do_install() {
    install -d ${D}/boot
    install -m 0644 ${S}/limine.conf ${D}/boot/limine.conf
}

do_deploy() {
    # Deploy the limine.conf file to the deploy directory for use in the image recipe
    install -m 0644 ${S}/limine.conf ${DEPLOYDIR}
}

FILES:${PN}:append = " /boot/limine.conf"
addtask deploy before do_build after do_compile
