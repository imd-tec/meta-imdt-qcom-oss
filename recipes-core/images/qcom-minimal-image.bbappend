# IMDT customizations layered onto meta-qcom-distro's qcom-minimal-image.
#
# Adds ADB, the IMDT tool/camera package set and SWUpdate (A/B rootfs)
# support.

# Allocate an extra 2G of spare space in the rootfs for .swu files to be
# stored and used. (value is in KiB)
IMAGE_ROOTFS_EXTRA_SPACE = "2097152"

# Enable ADB. qcom-minimal-image already inherits image-adbd but does not
# request the 'enable-adbd' feature, so adbd stays off. Setting it makes
# the class install the adbd packages and touch /etc/usb-debugging-enabled
# so the daemon comes up at boot. The LAVA swu-deploy job (and manual
# debugging) reach the board over adb.
IMAGE_FEATURES += "enable-adbd"

# Install imdt bsp support package so that README instructions can be
# followed and LAVA QA tests can run.
IMAGE_INSTALL:append = " \
    packagegroup-imdt-bsp-support \
"
# .swu bundles require a raw rootfs image to bundle. The .swu recipe
# (qcom-minimal-image.swu.bb) declares SWUPDATE_IMAGES_FSTYPES[...] = ".rootfs.ext4.gz".
IMAGE_FSTYPES:append = " ext4.gz"
