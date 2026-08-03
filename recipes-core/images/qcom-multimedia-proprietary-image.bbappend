# IMDT customizations layered onto meta-qcom-distro's qcom-multimedia-image.
#
# Adds ADB, an SSH server, the IMDT tool/camera package set and SWUpdate
# (A/B rootfs) support — shared with every IMDT image via the common include.
require imdt-image-common.inc

# Drop AudioReach, which meta-qcom-distro installs here whenever
# meta-audioreach is in the layer set. prm_audioreach_probe warns because the
# ADSP never answers its sync APM command, leaving the ADSP crashed and later
# udev finit_module calls deadlocked on a lock the failed probe held. Removing
# the packagegroup also drops audioreach-kernel's asoc-blacklist.conf, so the
# image falls back to the mainline q6apm path qcom-multimedia-image uses.
CORE_IMAGE_BASE_INSTALL:remove = "packagegroup-audioreach"
