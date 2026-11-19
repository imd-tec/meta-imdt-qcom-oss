# Make the qcomflash tarball self-contained so it can be flashed on its own.
#
# The boot firmware deploys flat into DEPLOY_DIR_IMAGE, and meta-qcom only
# picks up a fixed set of names from QCOM_BOOT_FILES_SUBDIR, so files such as
# NON-HLOS.bin, dspso.bin and the boot chain never reach the qcomflash dir.
# This copies in every file the rawprogram XMLs reference, plus the QDL
# programmer, drops vmlinux (debug only, nothing flashes it) and re-packs.

# QDL programmer(s) to ship next to the images, from DEPLOY_DIR_IMAGE.
IMDT_QCOMFLASH_PROGRAMMER ??= ""

# Also pack the bundle without rootfs.img and efi.bin, for the Ubuntu image.
IMDT_QCOMFLASH_BOOT ??= "0"

# Deploy imdt-boot's firmware bundle next to the qcomflash bundle it matches.
do_image_qcomflash[depends] += "${@'imdt-boot-firmware:do_deploy' if 'qcs8550' in d.getVar('MACHINEOVERRIDES').split(':') else ''}"

create_qcomflash_pkg:append() {
    for f in $(sed -n 's/.*filename="\([^"]\+\)".*/\1/p' rawprogram*.xml | sort -u) \
             ${IMDT_QCOMFLASH_PROGRAMMER}; do
        if [ ! -e "$f" ]; then
            if [ ! -e "${DEPLOY_DIR_IMAGE}/$f" ]; then
                bbfatal "qcomflash: $f is not in ${DEPLOY_DIR_IMAGE}"
            fi
            install -m 0644 "${DEPLOY_DIR_IMAGE}/$f" .
        fi
    done
    rm -f vmlinux

    # imdt-boot's manifest must describe exactly what this bundle flashes.
    manifest="${IMAGE_ROOTFS}${nonarch_libdir}/imdt-boot/manifest"
    if [ -f "$manifest" ]; then
        grep -v '^#' "$manifest" > ${WORKDIR}/imdt-boot-manifest.check
        while read -r base name size sha; do
            flashed=$(sed -n "s/.*filename=\"\([^\"]*\)\".*label=\"${base}_a\".*/\1/p" rawprogram[0-9].xml | head -n1)
            [ "$flashed" = "$name" ] || bbfatal "imdt-boot: ${base}_a flashes '$flashed', the manifest says $name"
            echo "$sha  $name" | sha256sum -c --status || bbfatal "imdt-boot: $name in the bundle differs from the manifest"
        done < ${WORKDIR}/imdt-boot-manifest.check
    fi

    # Same tarball as meta-qcom builds, now with the files above.
    ${IMAGE_CMD_TAR} --sparse --numeric-owner --transform="s,^\./,${IMAGE_BASENAME}-${MACHINE}/," -cf- . | pigz -p ${BB_NUMBER_THREADS} -9 -n --rsyncable > ${IMGDEPLOYDIR}/${IMAGE_NAME}.qcomflash.tar.gz

    if [ "${IMDT_QCOMFLASH_BOOT}" = "1" ]; then
        ${IMAGE_CMD_TAR} --numeric-owner --exclude=./rootfs.img --exclude=./efi.bin -cf- . | pigz -p ${BB_NUMBER_THREADS} -9 -n > ${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.qcomflash-boot.tar.gz
    fi
}
