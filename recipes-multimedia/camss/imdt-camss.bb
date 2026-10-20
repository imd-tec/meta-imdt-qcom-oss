SUMMARY = "Scripts for configuring cameras on the IMDT Qualcomm SBC"
DESCRIPTION = "Bash scripts for configuring media-ctl pipelines \
using the camss driver on IMDT Qualcomm platforms."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://qcs8550-csi0-ar1335.sh \
    file://qcs8550-csi0-ar1335.service \
    file://qcs6490-ar1335.sh \
    file://qcs6490-ar1335.service \
"

S = "${UNPACKDIR}"

inherit systemd

# Each board configures its own AR1335 media pipeline at boot.
CAMSS_PIPELINE = "qcs8550-csi0-ar1335"
CAMSS_PIPELINE:imdt-6490-sbc = "qcs6490-ar1335"
PACKAGE_ARCH = "${MACHINE_ARCH}"

SYSTEMD_SERVICE:${PN} = "${CAMSS_PIPELINE}.service"

# ${sbindir}, not /opt: /opt is /var on an OSTree system, which no deployment populates.
do_install() {
    install -D -m 0755 ${S}/${CAMSS_PIPELINE}.sh \
        ${D}${sbindir}/${CAMSS_PIPELINE}.sh

    install -D -m 0644 ${S}/${CAMSS_PIPELINE}.service \
        ${D}${systemd_system_unitdir}/${CAMSS_PIPELINE}.service
}


# The pipeline setup script relies on media-ctl and v4l2-ctl at runtime
# (media-ctl is split into its own package by the v4l-utils recipe).
RDEPENDS:${PN} += "media-ctl v4l-utils"
