SUMMARY = "Extra packages for IMDT SBC images"
DESCRIPTION = "Debugging, tooling, camera, SWUpdate and CI/test helper \
packages as used by the README.md and LAVA testing server."
LICENSE = "MIT"

# Some members (e.g. libgpiod -> libgpiod3) are dynamically renamed on the
# library ABI version, which an allarch package may not depend on. Make this
# packagegroup machine-specific so the QA 'packagegroup' check passes.
PACKAGE_ARCH = "${MACHINE_ARCH}"

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
