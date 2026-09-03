# IMDT FIT_DTB_COMPATIBLE entries, format: [<compatible, commas as _>] = "<dtb>
# [<overlay>...]". A separate inc on top of meta-qcom's because dtb-fit-image.bbclass
# parses late (inherit_defer) and would otherwise clobber flags set elsewhere.
# Entries whose DTBs aren't in KERNEL_DEVICETREE are skipped, so both boards share it.

require conf/machine/include/fit-dtb-compatible-linux-qcom.inc

FIT_DTB_COMPATIBLE[qcom_qcs6490-iot] = "qcs6490-imdt-sbc"

# UEFI matches the hyphen-separated suffix tokens (registered by the
# qcom-dtb-metadata bbappend). Base config = base DTB + display + ar1335-csi0.
FIT_DTB_COMPATIBLE[imdt_qcs8550-sbc-subtype5] = "qcs8550-imdt-sbc \
    qcs8550-imdt-sbc-display qcs8550-imdt-sbc-ar1335-csi0 qcs8550-imdt-sbc-cypd6125"
FIT_DTB_COMPATIBLE[imdt_qcs8550-sbc] = "qcs8550-imdt-sbc qcs8550-imdt-sbc-display qcs8550-imdt-sbc-ar1335-csi0"
