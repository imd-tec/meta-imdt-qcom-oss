SUMMARY = "SWUpdate .swu bundle for ${SWUPDATE_IMAGE} (A/B rootfs)"
DESCRIPTION = "Builds a .swu cpio archive that ships an ext4.gz of \
${SWUPDATE_IMAGE} together with a sw-description manifest. The image entry \
uses the on-target 'rootfs_ab' Lua handler (swupdate-imdt-handlers), \
which writes the image to the inactive slot and swaps rootfs_part on \
success."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit swupdate

COMPATIBLE_MACHINE = "qcs8550"

# The image this .swu wraps. Each concrete .swu recipe sets this before the
# require, and the shared sw-description expands the @@SWUPDATE_IMAGE@@ token
# from it.
SWUPDATE_IMAGE ?= ""

# meta-swupdate's swupdate.bbclass copies the named image's artifact into
# the .swu and substitutes @@FILENAME@@ tokens in sw-description. The
# fstype string is appended to the image basename verbatim, so include
# the '.rootfs' infix that modern Yocto's IMAGE_NAME_SUFFIX adds — the
# actual file on disk is e.g. qcom-minimal-image-imdt-8550-sbc.rootfs.ext4.gz.
SWUPDATE_IMAGES = "${SWUPDATE_IMAGE}"

# Ensure the rootfs is built before do_swuimage assembles the cpio.
do_swuimage[depends] += "${SWUPDATE_IMAGE}:do_image_complete"

# BitBake does not expand variables in a varflag *key*, so the per-image
# SWUPDATE_IMAGES_FSTYPES[<image>] entry and the build dependency that
# references the image by name must be set from python once SWUPDATE_IMAGE
# is known.
python () {
    img = d.getVar('SWUPDATE_IMAGE')
    if not img:
        bb.fatal("SWUPDATE_IMAGE must be set before requiring qcom-imdt-swu.inc")
    d.setVarFlag('SWUPDATE_IMAGES_FSTYPES', img, '.rootfs.ext4.gz')
}

SRC_URI = "file://sw-description"

# Expanded into sw-description's @@SWUPDATE_VERSION@@ token (the bbclass
# substitutes any @@VAR@@ with the BitBake variable of that name; plain
# @@VERSION@@ would expand the unset variable VERSION to "").
SWUPDATE_VERSION ?= "${PV}"
