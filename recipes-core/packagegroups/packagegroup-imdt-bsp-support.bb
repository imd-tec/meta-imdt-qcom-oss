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

# OSTree update helper and the mark-good service. imdt-ostree-bless clears the
# BLS counter on a good boot, which systemd-bless-boot can't here (no EFI vars).
# cdsp-htp-test is qcs8550-only for now: its hexagon-v73 skel dependency is
# board-arch-specific (see docs/lava-tests.md's dsp-htp suite).
RDEPENDS:${PN}:append:qcs8550 = " \
    ostree-imdt-update \
    imdt-ostree-bless \
    cdsp-htp-test \
"
