# IMDT customizations layered onto meta-qcom-distro's qcom-minimal-image.
#
# Adds the IMDT, tool/camera package set and SWUpdate (A/B rootfs)
# support. 

# Allocate an extra 2G of spare space in the rootfs for .swu files to be
# stored and used. (value is in KiB)
IMAGE_ROOTFS_EXTRA_SPACE = "2097152"

# Install imdt bsp support package so that README instructions can be
# followed and LAVA QA tests can run.
IMAGE_INSTALL:append = " \
    packagegroup-imdt-bsp-support \
"
# .swu bundles require a raw rootfs image to bundle. The .swu recipe
# (qcom-minimal-image.swu.bb) declares SWUPDATE_IMAGES_FSTYPES[...] = ".rootfs.ext4.gz".
IMAGE_FSTYPES:append = " ext4.gz"
