SUMMARY = "Extra packages for IMDT SBC images"
DESCRIPTION = "Debugging, tooling, camera, SWUpdate and CI/test helper \
packages as used by the README.md and LAVA testing server."
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
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
    coreutils \
    lava-ssh-keys \
"
