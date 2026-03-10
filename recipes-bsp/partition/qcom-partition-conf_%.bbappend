SRC_URI:append = " file://8550-hdk-gpt-87.1.zip;name=8550-hdk-gpt"

do_configure:append() {
    install -d ${S}/platforms/qcs8550-hdk
    cp -r  ${S}/../8550-hdk/* ${S}/platforms/qcs8550-hdk
}
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"