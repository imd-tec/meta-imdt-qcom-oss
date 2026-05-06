SUMMARY = "SWUpdate .swu bundle for imdt-image-base (A/B rootfs)"
DESCRIPTION = "Builds a .swu cpio archive that ships an ext4.gz of \
imdt-image-base together with a sw-description manifest declaring two \
selections (rootfs_a, rootfs_b). The on-target swupdate-rootfs wrapper \
picks the inverse of the active slot so the update always lands on the \
inactive partition; SWUpdate's bootenv handler swaps rootfs_part on \
success."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

COMPATIBLE_MACHINE = "qcs8550"

# meta-swupdate's swupdate.bbclass copies the named image's artifact into
# the .swu and substitutes @@FILENAME@@ tokens in sw-description. The
# fstype string is appended to the image basename verbatim, so include
# the '.rootfs' infix that modern Yocto's IMAGE_NAME_SUFFIX adds — the
# actual file on disk is e.g. imdt-image-base-imdt-8550-sbc.rootfs.ext4.gz.
SWUPDATE_IMAGES = "imdt-image-base"
SWUPDATE_IMAGES_FSTYPES[imdt-image-base] = ".rootfs.ext4.gz"

# Ensure the rootfs is built before do_swuimage assembles the cpio.
do_swuimage[depends] += "imdt-image-base:do_image_complete"

SRC_URI = "file://sw-description"

# Expanded into sw-description's @@VERSION@@ token.
SWUPDATE_VERSION ?= "${PV}"
