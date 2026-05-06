do_install:append:qcs8550() {
    # Mount the u-boot env FAT partition at /media/env. nofail keeps boot
    # going if the partition is missing.
    cat >> ${D}${sysconfdir}/fstab <<'EOF'

# u-boot environment (FAT partition labelled 'env', read by fw_printenv)
LABEL=UBOOT_ENV /media/env	vfat	defaults,noatime,nofail,umask=0022	0	0
EOF
    install -d ${D}/media/env
}
