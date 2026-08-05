FILESEXTRAPATHS:prepend := "${THISDIR}/linux-qcom-next:"

# We have a mix of patches that are in the process of upstreamed
# and patches that are WiP.
#
# Patches fetched from lore have to be dropped once the kernel that meta-qcom pins
# gains them, or do_patch fails. We track meta-qcom master, so its kernel SRCREV bumps arrive
# without any change here. The signature in the do_patch log is unmistakable:
#   Hunk #1 FAILED ... / Patch <name> can be reverse-applied
# "can be reverse-applied" means the change is already in the tree -- remove the entry
# and its SRC_URI[<name>.sha256sum] rather than trying to rebase it.
SRC_URI:append = " \
    https://lore.kernel.org/all/20260427-sm8550-sdhc4-support-v2-1-a4241f43ecd5@imd-tec.com/raw;downloadfilename=0001-sm8550-sdhc4-support.patch;apply=yes;striplevel=1;name=sdhc4 \
    file://0001-dt-bindings-vendor-prefixes-Add-IMDT.patch \
    file://0002-dt-bindings-qcom-Document-IMDT-QCS8550-SBC-and-SoM.patch \
    file://0003-arm64-dts-qcom-Add-IMDT-QCS8550-SBC.patch \
    file://0004-arm64-dts-qcom-qcs8550-imdt-sbc-Add-DSI-display-over.patch \
    file://0005-dt-bindings-media-i2c-Add-ON-Semiconductor-AR1335-se.patch \
    file://0006-media-i2c-ar1335-Add-ON-Semiconductor-AR1335-camera-.patch \
    file://0007-arm64-dts-qcom-qcs8550-imdt-sbc-Split-AR1335-CSI0-in.patch \
    file://0008-arm64-dts-qcom-qcs8550-imdt-sbc-Add-PCIe-switch-Key-.patch \
    file://0009-arm64-dts-qcom-qcs8550-imdt-sbc-enable-zap-shader.patch \
    file://0010-qcs8550-imdt-sbc-display-Enable-backlight-improve-po.patch \
    file://0011-arm64-dts-qcom-Add-support-for-the-IMDT-QCS6490-SBC-.patch \
    file://0012-arm64-dts-qcom-qcs6490-imdt-sbc-detach-eMMC-ICE.patch \
    file://configs/imdt.cfg \
"

SRC_URI[sdhc4.sha256sum]         = "b47391ea40077dbdef7d230d4a1e83fe33ba200ca8f4f9273fb1db98a1cadc7f"
# This QA fails on lore.kernel patch files even though the patches
# are being upstreamed.
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
