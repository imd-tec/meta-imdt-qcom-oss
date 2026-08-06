FILESEXTRAPATHS:prepend := "${THISDIR}/linux-qcom-next:"

# We have a mix of patches that are in the process of upstreamed
# and patches that are WiP.
#
# Patches that are being upstreamed have to be dropped once the kernel that meta-qcom
# pins gains them, or do_patch fails. We track meta-qcom master, so its kernel SRCREV bumps
# arrive without any change here. The signature in the do_patch log is unmistakable:
#   Hunk #1 FAILED ... / Patch <name> can be reverse-applied
# "can be reverse-applied" means the change is already in the tree -- remove the patch
# rather than trying to rebase it.
SRC_URI:append = " \
    file://0001-arm64-dts-qcom-sm8550-add-SDHC4-controller-node.patch \
    file://0002-dt-bindings-vendor-prefixes-Add-IMDT.patch \
    file://0003-dt-bindings-qcom-Document-IMDT-QCS8550-SBC-and-SoM.patch \
    file://0004-arm64-dts-qcom-Add-IMDT-QCS8550-SBC.patch \
    file://0005-arm64-dts-qcom-qcs8550-imdt-sbc-Add-DSI-display-over.patch \
    file://0006-dt-bindings-media-i2c-Add-ON-Semiconductor-AR1335-se.patch \
    file://0007-media-i2c-ar1335-Add-ON-Semiconductor-AR1335-camera-.patch \
    file://0008-arm64-dts-qcom-qcs8550-imdt-sbc-Split-AR1335-CSI0-in.patch \
    file://0009-arm64-dts-qcom-qcs8550-imdt-sbc-Add-PCIe-switch-Key-.patch \
    file://0010-arm64-dts-qcom-qcs8550-imdt-sbc-enable-zap-shader.patch \
    file://0011-qcs8550-imdt-sbc-display-Enable-backlight-improve-po.patch \
    file://0012-arm64-dts-qcom-Add-support-for-the-IMDT-QCS6490-SBC-.patch \
    file://0013-arm64-dts-qcom-qcs6490-imdt-sbc-detach-eMMC-inline-c.patch \
    file://0014-arm64-dts-qcom-qcs8550-imdt-som-Drop-LPM-mode-in-vre.patch \
    file://configs/imdt.cfg \
"

# Not every patch carries an Upstream-Status tag yet.
ERROR_QA:remove = "patch-status"

# Compile DTBs with -@ so __symbols__ are emitted and overlays
# can be applied at runtime (fdt apply / fdtoverlay / configfs).
EXTRA_OEMAKE:append = " DTC_FLAGS=-@"

# FIT /configurations entries for qclinuxfitImage (multi-dtb boot flow).
# dtb-fit-image.bbclass is pulled in via inherit_defer, so it (and the
# fit-dtb-compatible*.inc it requires) parses after this bbappend — setting
# FIT_DTB_COMPATIBLE flags directly here gets clobbered for keys meta-qcom's
# inc also defines. Instead point the class at our own inc, which requires
# meta-qcom's and then overrides on top.
LINUX_QCOM_FIT_DTB_COMPATIBLE = "conf/machine/include/imdt-fit-dtb-compatible.inc"
