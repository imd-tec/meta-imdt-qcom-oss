# This bbappend conditionally changes (Depending on the value of EFI_PROVIDER) the QCS8550 to boot using limine instead of systemd-boot since the 8550 HDK doesn't support UKI which is required for systemd-boot. 
# Limine allows us to boot the kernel directly without needing to create a UKI, which works around the issue with UKI on the 8550 HDK. 
# The bbappend also installs the DTB into the EFI partition which limine will look for when booting the kernel.
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
KERNEL_DEVICETREE:qcs8550 = "${QCOM_DTB_DEFAULT}"
# Install the DTB into the EFI partition due to UEFI core trying to load DTBs from here. 
dtb_folder() {
    install -d ${IMAGE_ROOTFS}${ESPFOLDER}${EFI_DTBS_FOLDER}
    install -m 0644 ${DEPLOY_DIR_IMAGE}/${QCOM_DTB_DEFAULT} ${IMAGE_ROOTFS}${ESPFOLDER}${EFI_DTBS_FOLDER}
}

install_kernel_image() {
    install -d ${IMAGE_ROOTFS}${ESPFOLDER}
    # Install the bare Image uncompressed for maximum compatibility
    install -m 0644 ${DEPLOY_DIR_IMAGE}/Image ${IMAGE_ROOTFS}${ESPFOLDER}/Image
}

# Unified kernel images (UKI ) doesn't work on the 8550 in LE 87.1, (Unknown why - Probably an issue in UEFI core)
remove_UKI(){
    # Remove the UKI if it exists since the 8550 HDK doesn't support it
    rm -f ${IMAGE_ROOTFS}${ESPFOLDER}/EFI/Linux/${UKI_FILENAME}

}
# This method installs extlinux.conf
install_u_boot_extlinux_entry() {
    install -d ${IMAGE_ROOTFS}${ESPFOLDER}/extlinux
    install -d ${DEPLOY_DIR_IMAGE}/extlinux/extlinux.conf ${IMAGE_ROOTFS}${ESPFOLDER}/extlinux/extlinux.conf
}

install_initramfs() {
    install -d ${IMAGE_ROOTFS}${ESPFOLDER}/EFI/Linux/
    install -m 0644 ${DEPLOY_DIR_IMAGE}/initramfs-rootfs-image-${MACHINE}.cpio.gz ${IMAGE_ROOTFS}${ESPFOLDER}/EFI/Linux/initramfs.cpio.gz
}

# Limine is a lightweight bootloader that can be used to boot the kernel directly without needing to create a UKI, which allows us to work around the issue with UKI on the 8550 HDK
install_limine() {
    install -d ${IMAGE_ROOTFS}${ESPFOLDER}
    # Install limine to the EFI partition so it can be used to boot the kernel since UKI doesn't work on the 8550 HDK
    # Install the limine loader entry for the 8550 HDK
    install -m 0644 ${DEPLOY_DIR_IMAGE}/limine.conf ${IMAGE_ROOTFS}${ESPFOLDER}/limine.conf
}

python __anonymous() {
    efi_provider = d.getVar('EFI_PROVIDER')
    pkg_install = d.getVar('PACKAGE_INSTALL') or ""
    pre_processing = d.getVar('IMAGE_PREPROCESS_COMMAND') or ""
    if efi_provider == 'limine':
        pkg_install = pkg_install.replace('systemd-boot', '')
        pkg_install = pkg_install.replace('u-boot-qcom', '')
        pkg_install += ' limine'
        pre_processing += ' dtb_folder install_kernel_image remove_UKI install_limine'
        d.setVar('IMAGE_PREPROCESS_COMMAND', pre_processing.strip())
    elif efi_provider == 'systemd-boot':
        pkg_install = pkg_install.replace('limine', '')
        pkg_install = pkg_install.replace('u-boot-qcom', '')
        pkg_install += ' systemd-boot'
    elif efi_provider == 'u-boot-qcom':
        pkg_install = pkg_install.replace('limine', '')
        pkg_install = pkg_install.replace('systemd-boot', '')
        pkg_install += ' u-boot-qcom'
        pre_processing += ' dtb_folder install_kernel_image remove_UKI'
        if d.getVar('UBOOT_EXTLINUX') == '1':
            pre_processing += ' dtb_folder install_kernel_image install_u_boot_extlinux_entry'
        d.setVar('IMAGE_PREPROCESS_COMMAND', pre_processing.strip())
    d.setVar('PACKAGE_INSTALL', pkg_install.strip())
    
}
