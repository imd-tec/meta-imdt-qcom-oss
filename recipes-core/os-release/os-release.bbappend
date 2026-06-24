# Embed the meta-imdt-qcom-oss git version into /etc/os-release.
META_IMDT_QCOM_OSS_VERSION = "${META_IMDT_LAYER_VERSION}"
OS_RELEASE_FIELDS:append = " META_IMDT_QCOM_OSS_VERSION"
