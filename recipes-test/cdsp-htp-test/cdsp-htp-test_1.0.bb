SUMMARY = "cDSP HTP (NPU) hardware QA test"
DESCRIPTION = "Runs a real MobileNetV2 model on the cDSP's Hexagon Tensor \
Processor via onnxruntime-qnn repeatedly for a fixed duration, so a session \
that wedges shortly after a successful first inference doesn't pass \
undetected. Used by the LAVA hardware test suite (see docs/lava-tests.md)."
LICENSE = "CLOSED"

SRC_URI = "file://cdsp-htp-test.cpp file://mobilenet_v2.onnx"
S = "${UNPACKDIR}"

DEPENDS = "onnxruntime onnxruntime-qnn"

# onnxruntime-qnn's provider plugin (libonnxruntime_providers_qnn.so) and
# qairt-sdk's backend libraries are loaded via RegisterExecutionProviderLibrary
# at runtime, not linked, so bitbake's shlibs scanner can't see them: RDEPENDS
# has to be explicit.
RDEPENDS:${PN} = "onnxruntime-qnn qairt-sdk qairt-sdk-hexagon-v73"

CXXFLAGS:append = " -I${STAGING_INCDIR}/onnxruntime"

do_compile() {
    ${CXX} ${CXXFLAGS} ${LDFLAGS} ${S}/cdsp-htp-test.cpp -o ${B}/cdsp-htp-test -lonnxruntime
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${B}/cdsp-htp-test ${D}${bindir}/cdsp-htp-test
    install -d ${D}${datadir}/cdsp-htp-test
    install -m 0644 ${S}/mobilenet_v2.onnx ${D}${datadir}/cdsp-htp-test/mobilenet_v2.onnx
}

FILES:${PN} += "${datadir}/cdsp-htp-test"
