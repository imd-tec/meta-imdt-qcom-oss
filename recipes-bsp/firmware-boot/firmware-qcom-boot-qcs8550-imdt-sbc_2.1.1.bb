require firmware-qcom-boot-qcs8550.inc

# QCS8550 LE 2.0 (BOOT.MXF 2.1.1.c1) non-HLOS firmware, POP DDR (LAA) variant,
# with the DtPlatformDxe FIT DTB selection. Built via docker/build-nonhlos.sh
# DDR_VARIANT=LAA (the default LAB/non-POP UEFI will not DDR-init this board).
SRC_URI = " \
    file://imdt-8550-sbc-fw-v2_1_1.zip;name=bootbinaries \
"
SRC_URI[bootbinaries.sha256sum] = "37513b3c13ae088bc2d188bec7311e1256150ff3a7246fd063de72a93c127054"

BOOTBINARIES = "imdt-8550-sbc"
# QCOM_BOOT_IMG_SUBDIR left default ("") so boot binaries deploy flat into
# DEPLOY_DIR_IMAGE where QCOM_BOOT_FILES_SUBDIR points qcomflash at them.
