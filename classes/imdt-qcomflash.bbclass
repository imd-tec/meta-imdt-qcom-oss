# Make the qcomflash tarball self-contained so it can be flashed on its own.
#
# The boot firmware deploys flat into DEPLOY_DIR_IMAGE, and meta-qcom only
# picks up a fixed set of names from QCOM_BOOT_FILES_SUBDIR, so files such as
# NON-HLOS.bin, dspso.bin and the boot chain never reach the qcomflash dir.
# This copies in every file the rawprogram XMLs reference, plus the QDL
# programmer, drops vmlinux (debug only, nothing flashes it) and re-packs.

# QDL programmer(s) to ship next to the images, from DEPLOY_DIR_IMAGE.
IMDT_QCOMFLASH_PROGRAMMER ??= ""

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

    # Same tarball as meta-qcom builds, now with the files above.
    ${IMAGE_CMD_TAR} --sparse --numeric-owner --transform="s,^\./,${IMAGE_BASENAME}-${MACHINE}/," -cf- . | pigz -p ${BB_NUMBER_THREADS} -9 -n --rsyncable > ${IMGDEPLOYDIR}/${IMAGE_NAME}.qcomflash.tar.gz
}
