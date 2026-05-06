# Selects the bootloader on QCS8550 via EFI_PROVIDER. Kernel Image and DTBs
# live in the rootfs /boot (installed by kernel-image / kernel-devicetree); the
# ESP only carries bootloader-owned files (limine.conf, extlinux.conf, etc.).
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PACKAGE_EXCLUDE = "kernel-image-*"

# UKI doesn't work on the 8550 in LE 87.1 (suspected UEFI core issue).
remove_UKI(){
    rm -f ${IMAGE_ROOTFS}${ESPFOLDER}/EFI/Linux/${UKI_FILENAME}
}

install_u_boot_extlinux_entry() {
    install -d ${IMAGE_ROOTFS}${ESPFOLDER}/extlinux
    install -d ${DEPLOY_DIR_IMAGE}/extlinux/extlinux.conf ${IMAGE_ROOTFS}${ESPFOLDER}/extlinux/extlinux.conf
}

install_initramfs() {
    install -d ${IMAGE_ROOTFS}${ESPFOLDER}/EFI/Linux/
    install -m 0644 ${DEPLOY_DIR_IMAGE}/initramfs-rootfs-image-${MACHINE}.cpio.gz ${IMAGE_ROOTFS}${ESPFOLDER}/EFI/Linux/initramfs.cpio.gz
}

install_limine() {
    install -d ${IMAGE_ROOTFS}${ESPFOLDER}
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
        pre_processing += ' remove_UKI install_limine'
        d.setVar('IMAGE_PREPROCESS_COMMAND', pre_processing.strip())
    elif efi_provider == 'systemd-boot':
        pkg_install = pkg_install.replace('limine', '')
        pkg_install = pkg_install.replace('u-boot-qcom', '')
        pkg_install += ' systemd-boot'
    elif efi_provider == 'u-boot-qcom':
        pkg_install = pkg_install.replace('limine', '')
        pkg_install = pkg_install.replace('systemd-boot', '')
        pkg_install += ' u-boot-qcom'
        pre_processing += ' remove_UKI'
        if d.getVar('UBOOT_EXTLINUX') == '1':
            pre_processing += ' install_u_boot_extlinux_entry'
        d.setVar('IMAGE_PREPROCESS_COMMAND', pre_processing.strip())
    d.setVar('PACKAGE_INSTALL', pkg_install.strip())
}
