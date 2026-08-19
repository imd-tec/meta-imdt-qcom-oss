SUMMARY = "Scripts for configuring cameras on the IMDT Qualcomm SBC"
DESCRIPTION = "Bash scripts for configuring media-ctl pipelines \
using the camss driver on IMDT Qualcomm platforms."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://qcs8550-csi0-ar1335.sh \
    file://qcs8550-csi0-ar1335.service \
"

S = "${UNPACKDIR}"

inherit systemd

# Configure the CSI0 AR1335 media pipeline automatically at boot.
SYSTEMD_SERVICE:${PN} = "qcs8550-csi0-ar1335.service"

# ${sbindir}, not /opt: /opt is /var on an OSTree system, which no deployment populates.
do_install() {
    install -D -m 0755 ${S}/qcs8550-csi0-ar1335.sh \
        ${D}${sbindir}/qcs8550-csi0-ar1335.sh

    install -D -m 0644 ${S}/qcs8550-csi0-ar1335.service \
        ${D}${systemd_system_unitdir}/qcs8550-csi0-ar1335.service
}


# The pipeline setup script relies on media-ctl and v4l2-ctl at runtime
# (media-ctl is split into its own package by the v4l-utils recipe).
RDEPENDS:${PN} += "media-ctl v4l-utils"
