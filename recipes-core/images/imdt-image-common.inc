# IMDT customizations shared by every image we ship on the QCS8550 SBC
# (qcom-minimal-image, qcom-multimedia-image, ...).
#
# Adds ADB, an SSH server, the IMDT tool/camera package set and SWUpdate
# (A/B rootfs) support. Required so that README instructions can be followed
# and the LAVA QA tests can deploy over adb and run over ssh.

# Enable ADB. The base images already inherit image-adbd but do not request
# the 'enable-adbd' feature, so adbd stays off. Setting it makes the class
# install the adbd packages and touch /etc/usb-debugging-enabled so the daemon
# comes up at boot. The LAVA swu-deploy job (and manual debugging) reach the
# board over adb. We also need ssh-server for running some of the LAVA tests.
IMAGE_FEATURES += "enable-adbd ssh-server-openssh"

# Install imdt bsp support package so that README instructions can be
# followed and LAVA QA tests can run.
IMAGE_INSTALL:append = " \
    packagegroup-imdt-bsp-support \
"
# .swu bundles require a raw rootfs image to bundle. The .swu recipes
# declare SWUPDATE_IMAGES_FSTYPES[...] = ".rootfs.ext4.gz".
IMAGE_FSTYPES:append = " ext4.gz"
