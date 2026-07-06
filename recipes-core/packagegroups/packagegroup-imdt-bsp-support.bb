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
    coreutils \
    lava-ssh-keys \
"

# The SWUpdate A/B update stack (handlers, U-Boot rollback confirmation and
# the swupdate daemon it serves) only exists for the QCS8550 SBC — the
# handler and rollback recipes are COMPATIBLE_MACHINE = "qcs8550", so pulling
# them in unconditionally breaks other machines (e.g. imdt-6490-sbc).
RDEPENDS:${PN}:append:qcs8550 = " \
    swupdate \
    swupdate-www \
    swupdate-imdt-handlers \
    uboot-mark-boot-successful \
"
