# Add support for the onsemi AR1335 sensor (CSI0) used on the IMDT QCS8550 SBC.

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
    file://0001-libcamera-Add-support-for-the-onsemi-AR1335-sensor.patch \
    file://0002-ipa-simple-Add-AR1335-tuning-file.patch \
"
# Add python support so that gstshark can be used
PACKAGECONFIG:append:qcom-distro = " python"
