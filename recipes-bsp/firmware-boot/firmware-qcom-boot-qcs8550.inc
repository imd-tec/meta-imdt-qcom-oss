DESCRIPTION = "QCOM NHLOS Firmware for Qualcomm QCS8550 platform (Built by IMDT Ltd)"
LICENSE = "CLOSED"
require recipes-bsp/firmware-boot/firmware-qcom-boot-common.inc
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

do_deploy:append() {
        SAIL_FILES="gpt_backup0.bin gpt_main0.bin prog_firehose_ddr.elf patch0.xml rawprogram0.xml"

        install -d ${DEPLOYDIR}/${QCOM_BOOT_IMG_SUBDIR}/sail_nor
        for sail_file in ${SAIL_FILES}; do
            install -m 0644 ${UNPACKDIR}/${BOOTBINARIES}/sail_nor/${sail_file} ${DEPLOYDIR}/${QCOM_BOOT_IMG_SUBDIR}/sail_nor
        done
}
