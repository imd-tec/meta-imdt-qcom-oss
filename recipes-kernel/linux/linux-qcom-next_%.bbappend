SRC_URI:remove = "git://github.com/qualcomm-linux/kernel.git;${SRCBRANCH};protocol=https"
SRC_URI:append = " git://git@github.com/imd-tec/imdt-qcom-oss-linux-dev.git;branch=master;protocol=ssh"
SRCREV = "0024308c2635a035890cc988f9c97868f918a2cf"
LINUX_VERSION = "7.0.0"