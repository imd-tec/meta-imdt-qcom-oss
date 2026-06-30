# IMDT customizations layered onto meta-qcom-distro's qcom-multimedia-image.
#
# Adds ADB, an SSH server, the IMDT tool/camera package set and SWUpdate
# (A/B rootfs) support — shared with every IMDT image via the common include.
require imdt-image-common.inc

# Ship the libcamera Python bindings alongside libcamera on the multimedia
# image (the recipe builds them via the 'pycamera' PACKAGECONFIG). This package
# RDEPENDS on python3, so it is only added here rather than to every image.
IMAGE_INSTALL:append = " \
    libcamera-pycamera \
"
