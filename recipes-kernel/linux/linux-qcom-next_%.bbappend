FILESEXTRAPATHS:prepend := "${THISDIR}/linux-qcom-next:"

SRC_URI:append = " \
    https://lore.kernel.org/all/20260427-sm8550-sdhc4-support-v2-1-a4241f43ecd5@imd-tec.com/raw;downloadfilename=0001-sm8550-sdhc4-support.patch;apply=yes;striplevel=1;name=sdhc4 \
    https://lore.kernel.org/all/20260428-imdt-dsi-display-v2-1-cf7294b5d7d6@imd-tec.com/raw;downloadfilename=0002-dsi-bindings.patch;apply=yes;striplevel=1;name=dsi_bindings \
    https://lore.kernel.org/all/20260428-imdt-dsi-display-v2-2-cf7294b5d7d6@imd-tec.com/raw;downloadfilename=0003-dsi-display.patch;apply=yes;striplevel=1;name=dsi_display \
    https://lore.kernel.org/linux-arm-msm/20260430-imdt-qcs8550-sbc-rfc-v1-1-4d2b6675eaa3@imd-tec.com/raw;downloadfilename=0004-imdt-prefix.patch;apply=yes;striplevel=1;name=imdt_prefix \
    https://lore.kernel.org/linux-arm-msm/20260430-imdt-qcs8550-sbc-rfc-v1-2-4d2b6675eaa3@imd-tec.com/raw;downloadfilename=0005-imdt-bindings.patch;apply=yes;striplevel=1;name=imdt_bindings \
    https://lore.kernel.org/linux-arm-msm/20260430-imdt-qcs8550-sbc-rfc-v1-3-4d2b6675eaa3@imd-tec.com/raw;downloadfilename=0006-imdt-qcs8550.patch;apply=yes;striplevel=1;name=imdt_qcs8550 \
    file://configs/imdt.cfg \
"

SRC_URI[sdhc4.sha256sum]         = "b47391ea40077dbdef7d230d4a1e83fe33ba200ca8f4f9273fb1db98a1cadc7f"
SRC_URI[dsi_bindings.sha256sum]  = "f09bd422b105c0f99b3028920d2edf4baf20e2cf583dd5ce857dd72fd634fdaa"
SRC_URI[dsi_display.sha256sum]   = "667468d0a8b426cb16f8b0768d51a79b45a18d0dbf702fe4e57abd88d943ccc3"
SRC_URI[imdt_prefix.sha256sum]   = "d72cc31882436722e4c4c006612449e6492d74fd1981c4c6e0cc16c0f6deec2c"
SRC_URI[imdt_bindings.sha256sum] = "c759d8893924518772501779255328b449fbd17273419ef290ea3a9e9888ec32"
SRC_URI[imdt_qcs8550.sha256sum]  = "f88e7bd72770a49efbb2f060ade2e3ed229e0342a8eb79d4eec8726c38b9a5e4"
# This QA fails on lore.kernel patch files even though the patches
# are being upstreamed. 
ERROR_QA:remove = "patch-status"
