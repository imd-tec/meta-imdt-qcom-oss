# imdt-8550-sbc runs the GPU on mainline msm DRM, so there is no KGSL.
FILESEXTRAPATHS:prepend:imdt-8550-sbc := "${THISDIR}/${PN}:"
SRC_URI:append:imdt-8550-sbc = " file://0001-gbm_msm-Allow-the-backend-without-KGSL.patch"
