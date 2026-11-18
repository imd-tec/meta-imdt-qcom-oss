SUMMARY = "Extra packages for IMDT SBC images"
DESCRIPTION = "Debugging, tooling, camera, OSTree update and CI/test helper \
packages as used by the README.md and LAVA testing server."
LICENSE = "MIT"

# Machine-specific (not allarch) so the QA 'packagegroup' check passes for
# ABI-renamed members like libgpiod -> libgpiod3.
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    iproute2 \
    alsa-utils-aplay \
    alsa-utils-speaker-test \
    i2c-tools \
    iperf3 \
    libgpiod-tools \
    libgpiod \
    media-ctl \
    v4l-utils \
    pciutils \
    usbutils \
    imdt-camss \
    coreutils \
    lava-ssh-keys \
    qcom-metadata-editor \
"

# OSTree update helper and the mark-good service. imdt-ostree-bless clears the
# BLS counter on a good boot, which systemd-bless-boot can't here (no EFI vars).
RDEPENDS:${PN}:append:qcs8550 = " \
    ostree-imdt-update \
    imdt-ostree-bless \
"

RDEPENDS:${PN}:append:qcs8550 = " audioreach-topology-imdt"

# Boot firmware check and A/B update, it needs ufs-utils from meta-filesystems.
# IMDT_BOOT_IMAGES_IN_ROOTFS = "0" leaves out the 58 MB of firmware images,
# then imdt-boot update takes the deployed imdt-boot-<machine>.tar.zst instead.
IMDT_BOOT_IMAGES_IN_ROOTFS ??= "1"
IMDT_BOOT_PACKAGES = "imdt-boot ${@'imdt-boot-firmware-images' if d.getVar('IMDT_BOOT_IMAGES_IN_ROOTFS') == '1' else ''}"
RDEPENDS:${PN}:append:qcs8550 = " \
    ${@bb.utils.contains('BBFILE_COLLECTIONS', 'filesystems-layer', d.getVar('IMDT_BOOT_PACKAGES'), '', d)} \
"
