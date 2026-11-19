HOMEPAGE = "https://github.com/imd-tec/qcom-oss-boot-updater"

SRC_URI = "git://github.com/imd-tec/qcom-oss-boot-updater.git;branch=master;protocol=https"
SRCREV = "1a728b43953565e249251d432b66676ed9def931"
PV = "0.1.0+git"

# The A/B switch follows the UFS boot LUN scheme of the QCS8550.
COMPATIBLE_MACHINE = "qcs8550"
