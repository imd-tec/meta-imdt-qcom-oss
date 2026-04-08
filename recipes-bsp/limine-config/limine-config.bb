SUMMARY = "Limine Bootloader Configuration"
DESCRIPTION = "This recipe provides the configuration file for the Limine Bootloader, which is used to boot Qualcomm boards instead of systemd-boot"
LICENSE = "CLOSED"
SRC_URI = "file://limine.conf"

inherit deploy

S = "${UNPACKDIR}"

do_patch() {
    # Update the limine.conf file with the correct dtb_path for the target device.
    # Use EFI_DTBS_FOLDER so Limine can find the DTB where the ESP image installs it,
    # and update the line deterministically to avoid duplicates on re-runs.
    if grep -q "^[[:space:]]*dtb_path:" "${S}/limine.conf"; then
        sed -i 's|^[[:space:]]*dtb_path:.*|    dtb_path: boot():'"${EFI_DTBS_FOLDER}"'/'"${QCOM_DTB_DEFAULT}"'|' "${S}/limine.conf"
    else
        echo "    dtb_path: boot():${EFI_DTBS_FOLDER}/${QCOM_DTB_DEFAULT}" >> "${S}/limine.conf"
    fi
}
 
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
