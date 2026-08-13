# Register the IMDT board (sbc, board-id 0x20), IMDT as an OEM (oem-id 1) and
# the QCS8550 SoC (msm-id 0x25b) in the qcom device-tree metadata blob so UEFI
# FIT selection can match imdt,qcs6490-sbc-imdt and imdt,qcs8550-sbc.
FILESEXTRAPATHS:prepend := "${THISDIR}/qcom-dtb-metadata:"

SRC_URI += "file://0001-metadata-add-IMDT-board-and-OEM.patch"
