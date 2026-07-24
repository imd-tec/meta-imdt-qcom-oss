# imdt-8550-sbc: drive the Adreno GPU with the mainline msm (a6xx) DRM driver
# instead of the downstream KGSL driver.
# Since to use the downstream KGSL driver you must have a downstream
# style DT for the GPU
do_install:append:imdt-8550-sbc() {
    install -d ${D}${sysconfdir}/modprobe.d
    printf '%s\n' \
        'blacklist msm_kgsl' \
        > ${D}${sysconfdir}/modprobe.d/qcom-adreno.conf
}
