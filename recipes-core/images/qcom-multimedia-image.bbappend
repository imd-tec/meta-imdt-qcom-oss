# IMDT customizations layered onto meta-qcom-distro's qcom-multimedia-image.
#
# Adds ADB, ssh, the IMDT tool/camera set and the OSTree update helpers.
require imdt-image-common.inc

# Ship the libcamera Python bindings alongside libcamera on the multimedia
# image (the recipe builds them via the 'pycamera' PACKAGECONFIG). This package
# RDEPENDS on python3, so it is only added here rather than to every image.
IMAGE_INSTALL:append = " \
    libcamera-pycamera \
"

# Remote desktop by default: Weston runs on the local display, over VNC, or
# both, selected at runtime from /etc/default/remote-desktop. Only added to
# images that have Weston. See docs/remote-desktop.md.
IMAGE_INSTALL:append = " \
    imdt-remote-desktop \
"
