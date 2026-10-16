# imdt-8550-sbc: drive the Adreno GPU with the mainline msm (a6xx) DRM driver
# instead of the downstream KGSL driver.
# Since to use the downstream KGSL driver you must have a downstream
# style DT for the GPU
FILESEXTRAPATHS:prepend:imdt-8550-sbc := "${THISDIR}/${PN}:"
SRC_URI:append:imdt-8550-sbc = " file://adreno_config.txt"

do_install:append:imdt-8550-sbc() {
    install -d ${D}${sysconfdir}/modprobe.d
    printf '%s\n' \
        'blacklist msm_kgsl' \
        > ${D}${sysconfdir}/modprobe.d/qcom-adreno.conf

    # GSL reads its settings from here; enable_drm lets it use msm DRM.
    install -d ${D}/data/vendor/gpu
    install -m 0644 ${UNPACKDIR}/adreno_config.txt ${D}/data/vendor/gpu/
}

FILES:${PN}-common:append:imdt-8550-sbc = " /data/vendor/gpu/adreno_config.txt"
