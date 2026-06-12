# NHLOS (modem/DSP/IPA) firmware for the IMDT QCS8550 SBC.
#
# Unlike the meta-qcom firmware-qcom-sm8550-hdk recipe (which expects the user
# to point NHLOS_URI at a NON-HLOS.bin in local.conf), this recipe ships the
# board's NON-HLOS.bin alongside it in files/ and dissects it into the
# individual .mbn/.jsn firmware files at build time.

DESCRIPTION = "QCOM NHLOS firmware for the IMDT QCS8550 SBC (dissected from NON-HLOS.bin)"
LICENSE = "CLOSED"

# QCS8550 is the same silicon as SM8550; the firmware must land in the SoC's
# canonical /lib/firmware/qcom/sm8550/ path so the kernel finds it. We give the
# packages a board-specific name (FW_QCOM_NAME) only to avoid colliding with the
# firmware-qcom-sm8550-hdk packages, while keeping the install dir on sm8550.
FW_QCOM_NAME = "sm8550-imdt-sbc"
FW_QCOM_SUBDIR = "sm8550"

FW_QCOM_LIST = "\
    adsp.mbn adsp_dtb.mbn adspr.jsn adsps.jsn adspua.jsn battmgr.jsn \
    cdsp.mbn cdsp_dtb.mbn cdspr.jsn \
    ipa_fws.mbn \
    modem.mbn modemr.jsn \
"

# NON-HLOS.bin ships with this recipe. firmware-qcom-nhlos.inc's get_nhlos_path()
# only handles an absolute file:// URI (a relative file://name resolves to an
# empty path), so build the URI from the absolute recipe directory.
NHLOS_URI = "file://${THISDIR}/files/NON-HLOS.bin"

S = "${UNPACKDIR}"

require recipes-bsp/firmware/firmware-qcom.inc
require recipes-bsp/firmware/firmware-qcom-nhlos.inc

# firmware-qcom-nhlos.inc empties the main package (FILES:${PN} = "") and
# firmware-qcom.inc makes every split package RDEPEND on it. Without an RPM for
# the (empty) main package that hard dependency is unsatisfiable, so the split
# packages get silently dropped from the rootfs. Allow the empty package so an
# RPM is produced and the dependency resolves.
ALLOW_EMPTY:${PN} = "1"

SPLIT_FIRMWARE_PACKAGES = "\
    linux-firmware-qcom-${FW_QCOM_NAME}-audio \
    linux-firmware-qcom-${FW_QCOM_NAME}-compute \
    linux-firmware-qcom-${FW_QCOM_NAME}-ipa \
    linux-firmware-qcom-${FW_QCOM_NAME}-modem \
"
