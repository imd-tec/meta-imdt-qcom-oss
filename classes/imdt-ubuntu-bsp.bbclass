# Export the board support files the Ubuntu image (ubuntu/) takes from Yocto.
#
# Packs the kernel Image, its modules, the firmware and the DSP/sensor data
# from this image's rootfs into ${IMAGE_LINK_NAME}.ubuntu-bsp.tar.zst, plus the
# kernel command line the board needs. ubuntu/assemble.sh overlays it onto the
# generic Ubuntu rootfs. Runs in the qcomflash step, not do_image, whose hash
# the OSTree classes already make sensitive.

# Paths (globs allowed) copied from the rootfs, relative to its root.
IMDT_UBUNTU_BSP_PATHS ?= " \
    usr/lib/modules \
    usr/lib/firmware \
    usr/share/qcom \
    etc/modprobe.d \
    usr/lib/modprobe.d \
    etc/modules-load.d \
    usr/lib/modules-load.d \
    etc/sensors \
    usr/sbin/*-ar1335.sh \
    usr/lib/systemd/system/*-ar1335.service \
    usr/bin/qcom-metadata-editor \
"

# Same as the OSTree boot entries, minus root= and ostree=.
IMDT_UBUNTU_CMDLINE ?= "console=ttyMSM0,115200 ${KERNEL_CMDLINE_EXTRA}"

imdt_ubuntu_bsp() {
    out="${WORKDIR}/ubuntu-bsp"
    rm -rf "$out"
    mkdir -p "$out/boot" "$out/usr/lib/imdt-ubuntu"
    (
        cd "${IMAGE_ROOTFS}"
        for p in ${IMDT_UBUNTU_BSP_PATHS}; do
            for f in $p; do
                [ -e "$f" ] || continue
                cp -a --no-preserve=ownership --parents "$f" "$out/"
            done
        done
    )
    install -m 0644 "${DEPLOY_DIR_IMAGE}/Image" "$out/boot/Image"
    echo "${IMDT_UBUNTU_CMDLINE}" | xargs > "$out/usr/lib/imdt-ubuntu/cmdline"
    # Not under fakeroot here, so record every file as root
    tar --owner=0 --group=0 --numeric-owner -C "$out" -cf - . | zstd -T0 -10 > "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.ubuntu-bsp.tar.zst"
    rm -rf "$out"
}

create_qcomflash_pkg:append() {
    imdt_ubuntu_bsp
}
do_image_qcomflash[depends] += "zstd-native:do_populate_sysroot virtual/kernel:do_deploy"
