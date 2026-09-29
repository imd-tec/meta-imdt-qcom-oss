DESCRIPTION = "Hexagon DSP binaries for the IMDT QCS8550 SBC"

DSPSO_SOC = "qcs8550"
DSPSO_DEVICE = "IMDT-QCS8550-SBC"

# Must match /sys/firmware/devicetree/base/model exactly: this is the key the
# fastrpc library loader uses to find DSP_LIBRARY_PATH under /usr/share/qcom.
DSPSO_DEVICE_MODEL = "IMDT QCS8550 SBC"

LICENSE = "CLOSED"
DEPENDS = "firmware-${DSP_PKG_NAME}"
S = "${UNPACKDIR}"

DSPSO_URI = "file://${THISDIR}/files/dspso.bin"

require recipes-bsp/hexagon-dspso/hexagon-dspso.inc

SKIP_FILEDEPS:hexagon-dsp-binaries-${DSP_PKG_NAME}-adsp = "1"
SKIP_FILEDEPS:hexagon-dsp-binaries-${DSP_PKG_NAME}-cdsp = "1"

# hexagon-dspso.inc's generate_config() writes DSP_LIBRARY_PATH as
# DSP_QCOM_SUBPATH, but do_install installs the adsp/cdsp binaries under
# DSP_QCOM_PATH/dsp/{adsp,cdsp} (an extra "dsp" segment). Without this fix
# the fastrpc loader resolves a path one directory short of where the
# binaries actually live and every DSP open fails with ENOENT.
generate_config() {
    if [ -n "${DSPSO_DEVICE_MODEL}" ] ; then
        cat >> ${B}/${BPN}.yaml << EOF
machines:
  ${DSPSO_DEVICE_MODEL}:
    DSP_LIBRARY_PATH: ${DSP_QCOM_SUBPATH}/dsp
EOF
    fi
}
