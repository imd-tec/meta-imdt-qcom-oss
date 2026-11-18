SUMMARY = "Boot firmware manifest and images for imdt-boot"
DESCRIPTION = "The boot firmware this image was built with: a manifest of \
sizes and sha256 sums, the zstd compressed partition images, and a deployed \
firmware bundle imdt-boot can take instead of the images."

# The images are the proprietary boot firmware.
LICENSE = "CLOSED"

require imdt-boot.inc

inherit deploy python3native

DEPENDS = "zstd-native"
PACKAGE_ARCH = "${MACHINE_ARCH}"

# The same inputs image_types_qcom gives the qcomflash bundle.
QCOM_PARTITION_CONF ?= "qcom-partition-conf"
do_compile[depends] += "${QCOM_PARTITION_CONF}:do_deploy ${QCOM_BOOT_FIRMWARE}:do_deploy"

do_configure[noexec] = "1"

do_compile() {
    rm -rf ${B}/out
    ${PYTHON} ${S}/scripts/imdt-boot-mkmanifest \
        --partitions ${DEPLOY_DIR_IMAGE}/${QCOM_PARTITION_FILES_SUBDIR} \
        --search ${DEPLOY_DIR_IMAGE}/${QCOM_BOOT_FILES_SUBDIR} \
        --search ${DEPLOY_DIR_IMAGE} \
        --version "${QCOM_BOOT_FIRMWARE}" \
        --out ${B}/out \
        --bundle ${B}/imdt-boot-${MACHINE}.tar.zst
}

do_install() {
    install -d ${D}${nonarch_libdir}/imdt-boot/images
    install -m 0644 ${B}/out/manifest ${D}${nonarch_libdir}/imdt-boot/
    install -m 0644 ${B}/out/images/*.zst ${D}${nonarch_libdir}/imdt-boot/images/
}

do_deploy() {
    install -m 0644 ${B}/imdt-boot-${MACHINE}.tar.zst ${DEPLOYDIR}/
}
addtask deploy after do_compile before do_build

PACKAGES =+ "${PN}-images"
FILES:${PN} = "${nonarch_libdir}/imdt-boot/manifest"
FILES:${PN}-images = "${nonarch_libdir}/imdt-boot/images"
