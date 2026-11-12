SUMMARY = "AudioReach topology for the IMDT QCS8550 SBC"
DESCRIPTION = "AudioReach topology for the TLV320AIC3101 codec on Primary MI2S. \
Built from QCS8550-IMDT-SBC.m4 with linux-msm/audioreach-topology d6bb205. \
It has no DisplayPort backend yet, so DP0 audio needs a rebuild."
LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/BSD-3-Clause;md5=550794465ba0ec5312d6919e203a55f9"

SRC_URI = " \
    file://QCS8550-IMDT-SBC.m4 \
    file://QCS8550-IMDT-SBC-tplg.bin \
"

S = "${UNPACKDIR}"

inherit allarch

do_install() {
    install -d ${D}${nonarch_base_libdir}/firmware/qcom/sm8550
    install -m 0644 ${S}/QCS8550-IMDT-SBC-tplg.bin ${D}${nonarch_base_libdir}/firmware/qcom/sm8550/
}

FILES:${PN} = "${nonarch_base_libdir}/firmware/qcom/sm8550/QCS8550-IMDT-SBC-tplg.bin"
