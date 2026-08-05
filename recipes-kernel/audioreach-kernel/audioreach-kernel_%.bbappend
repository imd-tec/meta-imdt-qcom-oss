# imdt-8550-sbc: the ADSP firmware (from NON-HLOS.bin) fatally
# crashes its sensor process.
do_install:append:imdt-8550-sbc() {
    install -d ${D}${sysconfdir}/modprobe.d
    printf '%s\n' \
        'blacklist audioreach_driver' \
        > ${D}${sysconfdir}/modprobe.d/imdt-audioreach-blacklist.conf
}
# module.bbclass narrows FILES:${PN} to the .ko, so ship the conf explicitly.
FILES:${PN}:append:imdt-8550-sbc = " ${sysconfdir}/modprobe.d/imdt-audioreach-blacklist.conf"
