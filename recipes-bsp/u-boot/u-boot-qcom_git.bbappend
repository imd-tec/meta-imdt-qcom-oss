SRC_URI:remove = "git://github.com/qualcomm-linux/u-boot.git;${SRCBRANCH};protocol=https;name=uboot"
SRC_URI:append = " git://git@github.com/imd-tec/qcom-u-boot-dev.git;branch=master;protocol=ssh"
SRCREV = "6c3b1c344c71121223efdc9672b7d5f8f02b53fc"

inherit deploy

# Qtestsign-native doesn't build due to python3-cryptography not building
DEPENDS:remove = "qtestsign-native"
# Clear BOARD_MBN_HEADER to prevent qtestsign being used
python () {
    d.setVar('BOARD_MBN_HEADER', '')
}
uboot_deploy_uefi() {
    install -d ${D}/boot/EFI/BOOT
    install -m 0644 ${B}/${builddir}/u-boot-app.efi ${D}/boot/EFI/BOOT/BOOTAA64.EFI
}

do_install:append() {

    if [ -f ${B}/${builddir}/u-boot-app.efi ]; then
        uboot_deploy_uefi
    fi
}
# Deploy the u-boot EFI binary to the deploy directory
uboot_deploy_config:append(){
    # Deploy the built EFI binary to the deploy directory for use in the image recipe
    install ${B}/${builddir}/u-boot-app.efi ${DEPLOY_DIR_IMAGE}/
    # Create a copy of the EFI binary with the required name for the image recipe
    install ${B}/${builddir}/u-boot-app.efi ${DEPLOY_DIR_IMAGE}/BOOTAA64.EFI 
}
