HOMEPAGE = "https://github.com/imd-tec/qcom-oss-boot-updater"

SRC_URI = "git://github.com/imd-tec/qcom-oss-boot-updater.git;branch=master;protocol=https"
SRCREV = "256fd0b38a920c30475dd3927c2c14155f8fdf81"
PV = "0.1.0+git"

# The A/B switch follows the UFS boot LUN scheme of the QCS8550.
COMPATIBLE_MACHINE = "qcs8550"
