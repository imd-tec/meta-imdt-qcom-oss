SUMMARY = "SWUpdate .swu bundle for qcom-minimal-image (A/B rootfs)"
DESCRIPTION = "Builds a .swu cpio archive that ships an ext4.gz of \
qcom-minimal-image together with a sw-description manifest. The image entry \
uses the on-target 'rootfs_ab' Lua handler (swupdate-imdt-handlers), \
which writes the image to the inactive slot and swaps rootfs_part on \
success."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

COMPATIBLE_MACHINE = "qcs8550"

# meta-swupdate's swupdate.bbclass copies the named image's artifact into
# the .swu and substitutes @@FILENAME@@ tokens in sw-description. The
# fstype string is appended to the image basename verbatim, so include
# the '.rootfs' infix that modern Yocto's IMAGE_NAME_SUFFIX adds — the
# actual file on disk is e.g. qcom-minimal-image-imdt-8550-sbc.rootfs.ext4.gz.
SWUPDATE_IMAGES = "qcom-minimal-image"
SWUPDATE_IMAGES_FSTYPES[qcom-minimal-image] = ".rootfs.ext4.gz"

# Ensure the rootfs is built before do_swuimage assembles the cpio.
do_swuimage[depends] += "qcom-minimal-image:do_image_complete"

SRC_URI = "file://sw-description"

# Expanded into sw-description's @@SWUPDATE_VERSION@@ token (the bbclass
# substitutes any @@VAR@@ with the BitBake variable of that name; plain
# @@VERSION@@ would expand the unset variable VERSION to "").
SWUPDATE_VERSION ?= "${PV}"
