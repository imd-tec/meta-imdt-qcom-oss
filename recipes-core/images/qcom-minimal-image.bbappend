# IMDT customizations layered onto meta-qcom-distro's qcom-minimal-image.
#
# Adds ADB, ssh, the IMDT tool/camera set and the OSTree update helpers.
require imdt-image-common.inc

# Kernel, firmware and boot bundle for the Ubuntu image (ubuntu/)
inherit imdt-ubuntu-bsp
IMDT_QCOMFLASH_BOOT = "1"

# cdsp-htp-test needs the LICENSE.qcom hexagon-v73 skel, so it can't go in the
# open-source multimedia image. qcs8550-only, see docs/lava-tests.md (dsp-htp).
IMAGE_INSTALL:append:qcs8550 = " cdsp-htp-test"

# SSC sensors (IMU, mag, temp/humidity) through sscrpcd
IMAGE_INSTALL:append:imdt-8550-sbc = " \
    qrtr \
    qcom-sensors-binaries \
"
