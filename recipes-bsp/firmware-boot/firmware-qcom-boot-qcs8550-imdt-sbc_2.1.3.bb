require firmware-qcom-boot-qcs8550.inc

# QCS8550 BOOT.MXF 2.1.3 non-HLOS firmware, POP DDR (LAA) variant, with the
# DtPlatformDxe FIT DTB-selection fixes. Built via docker/build-nonhlos.sh
# DDR_VARIANT=LAA (the default LAB/non-POP UEFI will not DDR-init this board).
SRC_URI = " \
    file://imdt-8550-sbc-fw-v2_1_3.zip;name=bootbinaries \
"
SRC_URI[bootbinaries.sha256sum] = "c053746417185db1b01794351d42968ac7226fe0a0d04f8f1b7a9185c147c58d"

BOOTBINARIES = "imdt-8550-sbc"
# QCOM_BOOT_IMG_SUBDIR left default ("") so boot binaries deploy flat into
# DEPLOY_DIR_IMAGE where QCOM_BOOT_FILES_SUBDIR points qcomflash at them.
