# The base recipe only installs the hexagon-v73 unsigned HTP libraries under
# reference-board paths (e.g. SA8775P-RIDE). QCS8550 is also hexagon-v73, but
# libcdsprpc's devicetree-model-keyed DSP_LIBRARY_PATH lookup (see
# hexagon-dspso-qcom-sm8550-imdt-sbc.bb) only searches our own board's path, so
# without this the QNN/HTP skel is never found on the IMDT QCS8550 SBC.
do_install:append:imdt-8550-sbc() {
    install -d ${D}${datadir}/qcom/qcs8550/Qualcomm/IMDT-QCS8550-SBC/dsp/cdsp
    cp -r ${S}/lib/hexagon-v73/unsigned/* ${D}${datadir}/qcom/qcs8550/Qualcomm/IMDT-QCS8550-SBC/dsp/cdsp
}

FILES:${PN}-hexagon-v73:append:imdt-8550-sbc = " ${datadir}/qcom/qcs8550/Qualcomm/IMDT-QCS8550-SBC/dsp/cdsp"
