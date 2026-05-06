# MACHINE_ESSENTIAL_EXTRA_RDEPENDS pulls kernel-image / kernel-devicetree for
# the rootfs (PC-like strategy — see qcom-qcs8550.inc), but the initramfs is
# unpacked by an already-running kernel and must not contain a kernel itself.
# Drop them from PACKAGE_INSTALL; PACKAGE_EXCLUDE alone is insufficient because
# dnf refuses when an explicitly-requested package is fully filtered by exclude.
PACKAGE_INSTALL:remove = "kernel-image kernel-devicetree"
