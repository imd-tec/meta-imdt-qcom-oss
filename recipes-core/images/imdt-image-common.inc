# IMDT customizations shared by every QCS8550 SBC image. Adds ADB, an SSH server
# and the IMDT bsp support package so the README steps and LAVA QA tests work.

# adbd is off in the base images (no enable-adbd feature). ADB is how the LAVA
# ostree-deploy job and manual debugging reach the board, ssh-server for tests.
IMAGE_FEATURES += "enable-adbd ssh-server-openssh"

IMAGE_INSTALL:append = " \
    packagegroup-imdt-bsp-support \
"
# OSTree image artefacts (ota-esp, ota-ext4, qcomflash) come from sota_qcom.
