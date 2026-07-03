# U-Boot "concept" fork (github.com/imd-tec/qcom-u-boot) for QCS8550.
# QCS8550 needs to use u-boot as a UEFI app, which is only supported in
# this fork. Compared to meta-qcom's u-boot-qcom recipe this also:
#   - Builds an initial env binary and wraps it in a FAT32 partition
#     image for boards that support CONFIG_ENV_IS_IN_FAT
#   - Deploys the built u-boot-app.efi to the deploy directory for use
#     in the image recipe
#   - Drops the qtestsign-native/MBN signing flow (the UEFI app does not
#     need an MBN header, and qtestsign-native doesn't build due to
#     python3-cryptography not building)

require recipes-bsp/u-boot/u-boot-common.inc
require recipes-bsp/u-boot/u-boot.inc

DEPENDS += "bc-native dtc-native gnutls-native python3-pyelftools-native xxd-native"
# Tools for wrapping the binary u-boot env into a FAT32 partition image
DEPENDS:append:qcs8550 = " dosfstools-native mtools-native"

COMPATIBLE_MACHINE = "(qcs8550)"

PV = "2026.02+git"

SRC_URI = "git://github.com/imd-tec/qcom-u-boot.git;branch=master;protocol=https"
SRCREV = "7b4825015a6cc3b1a22180039913b9d82696a2bb"
# Set the default overlay list to be blank
UBOOT_DEFAULT_FDT_OVERLAYS ?= ""

# Inject the overlay list into u-boot's Kconfig. Setting it via EXTRA_OEMAKE
# does not work because CONFIG_IMDT_QCS8550_OVERLAYS is a Kconfig string,
# read from .config rather than from the make command line. When UBOOT_CONFIG
# is set, u-boot.inc puts .config in ${B}/${config}-${type}, so mirror that
# loop here.
do_configure:append:qcs8550() {
    if [ -n "${UBOOT_CONFIG}" ]; then
        unset i j
        for config in ${UBOOT_MACHINE}; do
            i=$(expr $i + 1)
            for type in ${UBOOT_CONFIG}; do
                j=$(expr $j + 1)
                if [ $j -eq $i ]; then
                    ${S}/scripts/config --file ${B}/${config}-${type}/.config \
                        --set-str IMDT_QCS8550_OVERLAYS "${UBOOT_DEFAULT_FDT_OVERLAYS}"
                fi
            done
            unset j
        done
        unset i
    else
        ${S}/scripts/config --file ${B}/.config \
            --set-str IMDT_QCS8550_OVERLAYS "${UBOOT_DEFAULT_FDT_OVERLAYS}"
    fi
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
    # Install into ${DEPLOYDIR} (not ${DEPLOY_DIR_IMAGE}): the deploy bbclass
    # copies ${DEPLOYDIR} into ${DEPLOY_DIR_IMAGE} and, crucially, captures it
    # in the do_deploy sstate archive. Writing straight to ${DEPLOY_DIR_IMAGE}
    # is lost on any sstate-restore (setscene) build, since the function body
    # does not run then — leaving BOOTAA64.EFI absent from the deploy dir.
    # Deploy the built EFI binary for use in the image recipe
    install ${B}/${builddir}/u-boot-app.efi ${DEPLOYDIR}/
    # Create a copy of the EFI binary with the required name for the image recipe
    install ${B}/${builddir}/u-boot-app.efi ${DEPLOYDIR}/BOOTAA64.EFI
    if [ "${UBOOT_INITIAL_ENV_BINARY}" = "1" ]; then
        # Wrap the binary env (u-boot-initial-env-${type}.bin) in a FAT32 partition
        # image so a board with CONFIG_ENV_IS_IN_FAT can boot with a pre-seeded env.
        env_img="${DEPLOYDIR}/${UBOOT_ENV_IMG_NAME}"
        truncate -s ${UBOOT_ENV_IMG_SIZE_BYTES} $env_img
        mkfs.vfat -F 32 -S "${UBOOT_FAT32_LOGICAL_SIZE}" -n "${UBOOT_ENV_IMG_LABEL}" $env_img
        mcopy -i $env_img ${B}/${builddir}/u-boot-initial-env-${type}.bin ::/${UBOOT_ENV_FILENAME}
    fi
}
