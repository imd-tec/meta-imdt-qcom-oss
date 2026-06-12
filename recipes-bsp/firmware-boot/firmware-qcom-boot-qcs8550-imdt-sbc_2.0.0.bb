require firmware-qcom-boot-qcs8550.inc

SRC_URI = " \
    file://imdt-8550-sbc-fw-v2_0_0.zip;name=bootbinaries \
"
SRC_URI[bootbinaries.sha256sum] = "a1f440bb5e2b53f1e61d736512a1a14e75a091c364c4f9b5f4198bc585bcb659"

BOOTBINARIES = "imdt-8550-sbc"
# QCOM_BOOT_IMG_SUBDIR is left at its default ("") so the boot binaries deploy
# flat into DEPLOY_DIR_IMAGE, where the machine conf's QCOM_BOOT_FILES_SUBDIR
# points qcomflash (and stock qdl) at them.
