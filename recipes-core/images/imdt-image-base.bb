SUMMARY = "IMDT Base image for QCOM SBC using ADB for debugging"
DESCRIPTION = "This image provides a small Linux environment for Qualcomm boards, with ADB enabled for debugging purposes. It includes the necessary tools and configurations to allow developers to connect to the device using ADB and perform debugging tasks."

LICENSE = "MIT"

require recipes-core/images/core-image-base.bb

# Allocate an extra 2G of spare space in the rootfs (value is in KiB)
IMAGE_ROOTFS_EXTRA_SPACE = "2097152"

# Enable ADB
IMAGE_FEATURES += "enable-adbd"
inherit image-adbd

IMAGE_INSTALL:append = " \
    android-tools-adbd \
    iproute2 \
    i2c-tools \
    iperf3 \
    libgpiod-tools \
    libgpiod \
    media-ctl \
    v4l-utils \
    pciutils \
    usbutils \
    imdt-camss \
    swupdate \
    swupdate-www \
    swupdate-imdt-handlers \
    uboot-mark-boot-successful \
"

# .swu bundles require a raw rootfs image to bundle. The .swu recipe
# (imdt-image-base.swu.bb) declares SWUPDATE_IMAGES_FSTYPES[...] = ".rootfs.ext4.gz".
IMAGE_FSTYPES:append = " ext4.gz"
