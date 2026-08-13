do_install:append:qcs8550() {
    # Mount the ESP at /boot so OSTree can manage systemd-boot + its BLS entries.
    # nofail keeps boot going if the partition is missing.
    cat >> ${D}${sysconfdir}/fstab <<'EOF'

# EFI System Partition = /boot (systemd-boot + OSTree BLS entries)
PARTLABEL=efi /boot	vfat	rw,noatime,nofail,umask=0077	0	2
EOF

    # /etc/hwrevision: board identity (<board> <revision>).
    echo "imdt-8550-sbc 1.0" > ${D}${sysconfdir}/hwrevision
}
