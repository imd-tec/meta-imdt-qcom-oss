# IMDT FIT_DTB_COMPATIBLE entries for qclinuxfitImage (multi-dtb boot flow).
#
# Syntax (meta-qcom commit 330717eb inverted the key direction):
#   FIT_DTB_COMPATIBLE[<compatible, commas encoded as _>] = "<dtb-stem> [<overlay-stem>...]"
#
# This file is selected via LINUX_QCOM_FIT_DTB_COMPATIBLE in the
# linux-qcom-next bbappend. It must be a separate inc required on top of
# meta-qcom's file because dtb-fit-image.bbclass is pulled in with
# inherit_defer, so it parses AFTER the recipe and all bbappends; any
# FIT_DTB_COMPATIBLE flag set in a machine conf or bbappend is clobbered
# by meta-qcom's inc for keys both define (qcom_qcs6490-iot maps to
# qcs6490-rb3gen2 there). Overriding here, after the require, wins.
#
# Entries whose DTBs are not in KERNEL_DEVICETREE are skipped per machine,
# so both boards' entries can safely live in this shared file.

require conf/machine/include/fit-dtb-compatible-linux-qcom.inc

FIT_DTB_COMPATIBLE[qcom_qcs6490-iot] = "qcs6490-imdt-sbc"
FIT_DTB_COMPATIBLE[imdt_qcs8550-sbc] = "qcs8550-imdt-sbc"
