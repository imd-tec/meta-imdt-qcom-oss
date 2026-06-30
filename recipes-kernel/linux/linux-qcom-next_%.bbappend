FILESEXTRAPATHS:prepend := "${THISDIR}/linux-qcom-next:"

# We have a mix of patches that are in the process of upstreamed
# and patches that are WiP.
SRC_URI:append = " \
    https://lore.kernel.org/all/20260427-sm8550-sdhc4-support-v2-1-a4241f43ecd5@imd-tec.com/raw;downloadfilename=0001-sm8550-sdhc4-support.patch;apply=yes;striplevel=1;name=sdhc4 \
    https://lore.kernel.org/all/20260428-imdt-dsi-display-v2-1-cf7294b5d7d6@imd-tec.com/raw;downloadfilename=0002-dsi-bindings.patch;apply=yes;striplevel=1;name=dsi_bindings \
    https://lore.kernel.org/all/20260428-imdt-dsi-display-v2-2-cf7294b5d7d6@imd-tec.com/raw;downloadfilename=0003-dsi-display.patch;apply=yes;striplevel=1;name=dsi_display \
    file://0001-dt-bindings-vendor-prefixes-Add-IMDT.patch \
    file://0002-dt-bindings-qcom-Document-IMDT-QCS8550-SBC-and-SoM.patch \
    file://0003-arm64-dts-qcom-Add-IMDT-QCS8550-SBC.patch \
    file://0004-arm64-dts-qcom-qcs8550-imdt-sbc-Add-DSI-display-over.patch \
    file://0005-dt-bindings-media-i2c-Add-ON-Semiconductor-AR1335-se.patch \
    file://0006-media-i2c-ar1335-Add-ON-Semiconductor-AR1335-camera-.patch \
    file://0007-media-i2c-ar1335-Convert-to-V4L2-CCI-and-fix-streami.patch \
    file://0008-arm64-dts-qcom-qcs8550-imdt-sbc-Split-AR1335-CSI0-in.patch \
    file://0009-arm64-dts-qcom-qcs8550-imdt-sbc-Add-PCIe-switch-Key-.patch \
    file://0010-arm64-dts-qcom-qcs8550-imdt-sbc-enable-zap-shader.patch \
    file://0011-qcs8550-imdt-sbc-display-Enable-backlight-improve-po.patch \
    file://configs/imdt.cfg \
"

SRC_URI[sdhc4.sha256sum]         = "b47391ea40077dbdef7d230d4a1e83fe33ba200ca8f4f9273fb1db98a1cadc7f"
SRC_URI[dsi_bindings.sha256sum]  = "f09bd422b105c0f99b3028920d2edf4baf20e2cf583dd5ce857dd72fd634fdaa"
SRC_URI[dsi_display.sha256sum]   = "667468d0a8b426cb16f8b0768d51a79b45a18d0dbf702fe4e57abd88d943ccc3"
# This QA fails on lore.kernel patch files even though the patches
# are being upstreamed.
ERROR_QA:remove = "patch-status"

# Compile DTBs with -@ so __symbols__ are emitted and overlays
# can be applied at runtime (fdt apply / fdtoverlay / configfs).
EXTRA_OEMAKE:append = " DTC_FLAGS=-@"
