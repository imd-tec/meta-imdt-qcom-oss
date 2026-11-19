HOMEPAGE = "https://github.com/imd-tec/qcom-oss-boot-updater"

SRC_URI = "git://github.com/imd-tec/qcom-oss-boot-updater.git;branch=master;protocol=https"
SRCREV = "b14786bdea959e3c953a4a516d57cf3b1db838c4"
PV = "0.1.0+git"

# The A/B switch follows the UFS boot LUN scheme of the QCS8550.
COMPATIBLE_MACHINE = "qcs8550"
