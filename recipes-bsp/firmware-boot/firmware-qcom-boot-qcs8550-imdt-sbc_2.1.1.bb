require firmware-qcom-boot-qcs8550.inc

# QCS8550 LE 2.0 (BOOT.MXF 2.1.1.c1) non-HLOS firmware, POP DDR (LAA) variant,
# with the DtPlatformDxe FIT DTB selection. Built via docker/build-nonhlos.sh
# DDR_VARIANT=LAA (the default LAB/non-POP UEFI will not DDR-init this board).
SRC_URI = " \
    file://imdt-8550-sbc-fw-v2_1_1.zip;name=bootbinaries \
"
SRC_URI[bootbinaries.sha256sum] = "05782073e81a83c7174c6deab70b45be0d445ac74b3c9da20b32622d605d9fa0"

BOOTBINARIES = "imdt-8550-sbc"
# QCOM_BOOT_IMG_SUBDIR left default ("") so boot binaries deploy flat into
# DEPLOY_DIR_IMAGE where QCOM_BOOT_FILES_SUBDIR points qcomflash at them.
