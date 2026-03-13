# This bbappend conditionally changes (Depending on the value of EFI_PROVIDER) the QCS8550 to boot using limine instead of systemd-boot since the 8550 HDK doesn't support UKI which is required for systemd-boot. 
# Limine allows us to boot the kernel directly without needing to create a UKI, which works around the issue with UKI on the 8550 HDK. 
# The bbappend also installs the DTB into the EFI partition which limine will look for when booting the kernel.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
KERNEL_DEVICETREE:qcs8550 = "${QCOM_DTB_DEFAULT}"
# Install the DTB into the EFI partition due to UEFI core trying to load DTBs from here. 
dtb_folder() {
    install -d ${IMAGE_ROOTFS}${ESPFOLDER}/dtb/
    install -m 0644 ${DEPLOY_DIR_IMAGE}/${QCOM_DTB_DEFAULT} ${IMAGE_ROOTFS}${ESPFOLDER}/dtb/
}

# Unified kernel images (UKI ) doesn't work on the 8550 in LE 87.1, (Unknown why - Probably an issue in UEFI core)
remove_UKI(){
    # Remove the UKI if it exists since the 8550 HDK doesn't support it
    rm -f ${IMAGE_ROOTFS}${ESPFOLDER}/EFI/Linux/${UKI_FILENAME}

}

# Limine is a lightweight bootloader that can be used to boot the kernel directly without needing to create a UKI, which allows us to work around the issue with UKI on the 8550 HDK
install_limine() {
    install -d ${IMAGE_ROOTFS}${ESPFOLDER}
    # Install limine to the EFI partition so it can be used to boot the kernel since UKI doesn't work on the 8550 HDK
    # Install the bare Image uncompressed
    install -m 0644 ${DEPLOY_DIR_IMAGE}/Image ${IMAGE_ROOTFS}${ESPFOLDER}/Image
    # Install the limine loader entry for the 8550 HDK
    install -m 0644 ${DEPLOY_DIR_IMAGE}/limine.conf ${IMAGE_ROOTFS}${ESPFOLDER}/limine.conf
}

python __anonymous() {
    efi_provider = d.getVar('EFI_PROVIDER')
    pkg_install = d.getVar('PACKAGE_INSTALL') or ""
    pre_processing = d.getVar('IMAGE_PREPROCESS_COMMAND') or ""
    if efi_provider == 'limine':
        pkg_install = pkg_install.replace('systemd-boot', '')
        pkg_install += ' limine'
        pre_processing += ' dtb_folder remove_UKI install_limine'
        d.setVar('IMAGE_PREPROCESS_COMMAND', pre_processing.strip())
    elif efi_provider == 'systemd-boot':
        pkg_install = pkg_install.replace('limine', '')
        pkg_install += ' systemd-boot'
    d.setVar('PACKAGE_INSTALL', pkg_install.strip())
    
}
