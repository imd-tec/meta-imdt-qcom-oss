# Register the IMDT board (sbc, board-id 0x20) and IMDT as an OEM (oem-id 1)
# in the qcom device-tree metadata blob so UEFI FIT selection can match
# imdt,qcs6490-sbc-imdt and imdt,qcs8550-sbc.
FILESEXTRAPATHS:prepend := "${THISDIR}/qcom-dtb-metadata:"

SRC_URI += "file://0001-metadata-add-IMDT-board-and-OEM.patch"
