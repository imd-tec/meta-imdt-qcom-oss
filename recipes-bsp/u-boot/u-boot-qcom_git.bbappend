# QCS8550 U-boot changes
# For QCS8550 needs to use u-boot as a UEFI app
# This is only supported in the concept u-boot fork
# There are some other changes that his handles:
#   - Building an initial env binary and wrapping it in a FAT32
#     partition image for boards that support CONFIG_ENV_IS_IN_FAT
#   - Deploying the built u-boot-app.efi to the deploy directory for use in the image recipe
#   - Removing the qtestsign-native dependency since it doesn't build due to
#     python3-cryptography not building
SRC_URI:remove:qcs8550 = "git://github.com/qualcomm-linux/u-boot.git;${SRCBRANCH};protocol=https;name=uboot"
SRC_URI:append:qcs8550 = " git://git@github.com/imd-tec/qcom-u-boot-dev.git;branch=master;protocol=ssh"
SRCREV:qcs8550 = "b36d1b4c35832518e530295a4e9167dcfcf29256"

inherit deploy

# Qtestsign-native doesn't build due to python3-cryptography not building
DEPENDS:remove:qcs8550 = "qtestsign-native"

# Tools for wrapping the binary u-boot env into a FAT32 partition image
DEPENDS:append:qcs8550 = " dosfstools-native mtools-native"

python () {
    d.setVar('BOARD_MBN_HEADER', '')
}
uboot_deploy_uefi() {
    install -d ${D}/boot/EFI/BOOT
    install -m 0644 ${B}/${builddir}/u-boot-app.efi ${D}/boot/EFI/BOOT/BOOTAA64.EFI
}

do_install:append:qcs8550() {

    if [ -f ${B}/${builddir}/u-boot-app.efi ]; then
        uboot_deploy_uefi
    fi
}
# Deploy the u-boot EFI binary to the deploy directory
uboot_deploy_config:append:qcs8550() {
    # Deploy the built EFI binary to the deploy directory for use in the image recipe
    install ${B}/${builddir}/u-boot-app.efi ${DEPLOY_DIR_IMAGE}/
    # Create a copy of the EFI binary with the required name for the image recipe
    install ${B}/${builddir}/u-boot-app.efi ${DEPLOY_DIR_IMAGE}/BOOTAA64.EFI
    if [ "${UBOOT_INITIAL_ENV_BINARY}" = "1" ]; then
        # Wrap the binary env (u-boot-initial-env-${type}.bin) in a FAT32 partition
        # image so a board with CONFIG_ENV_IS_IN_FAT can boot with a pre-seeded env.
        env_img="${DEPLOY_DIR_IMAGE}/${UBOOT_ENV_IMG_NAME}"
        truncate -s ${UBOOT_ENV_IMG_SIZE_BYTES} $env_img
        mkfs.vfat -F 32 -S "${UBOOT_FAT32_LOGICAL_SIZE}" -n "${UBOOT_ENV_IMG_LABEL}" $env_img
        mcopy -i $env_img ${B}/${builddir}/u-boot-initial-env-${type}.bin ::/${UBOOT_ENV_FILENAME}
    fi
}

