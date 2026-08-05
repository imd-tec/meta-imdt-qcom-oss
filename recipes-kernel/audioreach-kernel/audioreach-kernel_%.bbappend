# Stop audioreach_driver auto-loading: when the closed ADSP firmware's sensor
# process crashes at boot its probe livelocks two CPUs until a power cycle.
do_install:append:imdt-8550-sbc() {
    install -d ${D}${sysconfdir}/modprobe.d
    printf '%s\n' \
        'blacklist audioreach_driver' \
        > ${D}${sysconfdir}/modprobe.d/imdt-audioreach-blacklist.conf
}
# module.bbclass narrows FILES:${PN} to the .ko, so ship the conf explicitly.
FILES:${PN}:append:imdt-8550-sbc = " ${sysconfdir}/modprobe.d/imdt-audioreach-blacklist.conf"
