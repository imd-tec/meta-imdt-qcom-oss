# IMDT customizations layered onto meta-qcom-distro's qcom-console-image.
#
# Adds the IMDT, tool/camera package set and SWUpdate (A/B rootfs)
# support. 

# Allocate an extra 2G of spare space in the rootfs for .swu files to be
# stored and used. (value is in KiB)
IMAGE_ROOTFS_EXTRA_SPACE = "2097152"

# The IMDT tool/camera/SWUpdate/CI package set, grouped in the
# imdt-extra-packages packagegroup (recipes-core/packagegroups).
IMAGE_INSTALL:append = " imdt-extra-packages"
# .swu bundles require a raw rootfs image to bundle. The .swu recipe
# (qcom-console-image.swu.bb) declares SWUPDATE_IMAGES_FSTYPES[...] = ".rootfs.ext4.gz".
IMAGE_FSTYPES:append = " ext4.gz"
