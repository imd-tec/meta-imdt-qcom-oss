#!/bin/bash
# Build a flashable Ubuntu bundle for one board.
#
# Overlays the Yocto board files (kernel, modules, firmware) onto the debos
# rootfs, builds its initramfs, an ESP with systemd-boot and an ext4 rootfs
# labelled otaroot, and puts both into the Yocto boot bundle in place of the
# OSTree efi.bin and rootfs.img. The rootfs must derive from the IMDT generic
# one (ubuntu/imdt-ubuntu.yaml). Run as root; needs zstd, mtools, dosfstools,
# e2fsprogs, kmod, and arm64 binfmt when not on an arm64 host.
set -euo pipefail

if [ $# -ne 5 ]; then
    echo "Usage: $0 <machine> <rootfs.tar.zst> <ubuntu-bsp.tar.zst> <qcomflash-boot.tar.gz> <outdir>" >&2
    exit 1
fi
MACHINE=$1
ROOTFS_TAR=$(realpath "$2")
BSP_TAR=$(realpath "$3")
BOOT_TAR=$(realpath "$4")
OUT=$(realpath "$5")
# BUNDLE_NAME picks the bundle name, e.g. for a product rootfs
NAME="${BUNDLE_NAME:-ubuntu-desktop}-${MACHINE}"

WORK=$(mktemp -d -p "${WORKDIR:-/var/tmp}" ubuntu-assemble.XXXXXX)
R="$WORK/rootfs"
cleanup() {
    for m in dev/pts dev proc sys; do
        mountpoint -q "$R/$m" && umount "$R/$m" || true
    done
    rm -rf "$WORK"
}
trap cleanup EXIT

echo "=== Unpack rootfs and board files"
mkdir -p "$R" "$WORK/bsp"
# Every xattr namespace, or file capabilities (security.capability) are lost
zstd -dc "$ROOTFS_TAR" | tar -xpf - --numeric-owner --xattrs --xattrs-include='*' --acls -C "$R"
zstd -dc "$BSP_TAR" | tar -xpf - --numeric-owner -C "$WORK/bsp"
KVER=$(ls "$WORK/bsp/usr/lib/modules")
CMDLINE=$(cat "$WORK/bsp/usr/lib/imdt-ubuntu/cmdline")
echo "kernel $KVER, cmdline: $CMDLINE"

for d in etc usr; do
    [ -d "$WORK/bsp/$d" ] && cp -a "$WORK/bsp/$d/." "$R/$d/"
done
install -m 0644 "$WORK/bsp/boot/Image" "$R/boot/Image"
install -m 0755 "$(dirname "$0")/initramfs/imdt-firmware" "$R/etc/initramfs-tools/hooks/imdt-firmware"
depmod -b "$R" "$KVER"

echo "=== initramfs"
mount -t proc proc "$R/proc"
mount -t sysfs sys "$R/sys"
mount --bind /dev "$R/dev"
mount --bind /dev/pts "$R/dev/pts"
for s in "$R"/usr/lib/systemd/system/*-ar1335.service; do
    [ -e "$s" ] && chroot "$R" systemctl enable "$(basename "$s")"
done
chroot "$R" update-initramfs -c -k "$KVER"

echo "=== Checks"
fail() { echo "CHECK FAILED: $*" >&2; exit 1; }
# Drivers whose firmware lives on the rootfs must not load from the initramfs
INITRD_LIST=$(chroot "$R" lsinitramfs "/boot/initrd.img-$KVER")
grep -q '\.ko' <<<"$INITRD_LIST" || fail "could not list the initramfs"
INITRD_KO=$(grep -E '/(qcom_q6v5_pas|qcom-iris|ipa)\.ko' <<<"$INITRD_LIST" || true)
[ -z "$INITRD_KO" ] || fail "initramfs loads drivers without their firmware: $INITRD_KO"
DEVS=$(find "$R" -path "$R/dev" -prune -o \( -type b -o -type c \) -print)
[ -z "$DEVS" ] || fail "device nodes outside /dev: $DEVS"
chroot "$R" getcap /usr/lib/snapd/snap-confine | grep -q cap_ || fail "file capabilities lost"
! ls "$R"/etc/ssh/ssh_host_* >/dev/null 2>&1 || fail "SSH host keys baked in"
[ ! -s "$R/etc/machine-id" ] || fail "machine-id baked in"
[ -L "$R/etc/systemd/system/multi-user.target.wants/ssh-host-keys.service" ] || fail "ssh-host-keys.service not enabled"
[ -x "$R/usr/sbin/cdsprpcd" ] && [ -e "$R/usr/lib/libcdsprpc.so" ] || fail "FastRPC missing"
for m in dev/pts dev sys proc; do umount "$R/$m"; done

echo "=== Boot bundle"
B="$WORK/$NAME"
mkdir -p "$B"
tar -xzf "$BOOT_TAR" -C "$B"

# ESP size and sector size from the efi partition entry (4K on UFS, 512 on eMMC)
EFI_ENTRY=$(grep -h 'filename="efi.bin"' "$B"/rawprogram*.xml | head -n1)
SECTORS=$(sed 's/.*num_partition_sectors="\([0-9]*\)".*/\1/' <<<"$EFI_ENTRY")
SECTOR=$(sed 's/.*SECTOR_SIZE_IN_BYTES="\([0-9]*\)".*/\1/' <<<"$EFI_ENTRY")
echo "efi partition: $SECTORS sectors of $SECTOR bytes"

ESP="$B/efi.bin"
rm -f "$ESP"
truncate -s $((SECTORS * SECTOR)) "$ESP"
mkfs.vfat -F 32 -S "$SECTOR" -n EFI "$ESP" >/dev/null
cat > "$WORK/loader.conf" <<EOF
default ubuntu.conf
timeout 0
EOF
# The 4K desktop leaves the default 32 MiB CMA too small for libcamera's soft ISP
cat > "$WORK/ubuntu.conf" <<EOF
title   Ubuntu 26.04 (${MACHINE})
linux   /Image
initrd  /initrd.img
options root=LABEL=otaroot rw rootwait ${CMDLINE} cma=256M
EOF
export MTOOLS_SKIP_CHECK=1
mmd -i "$ESP" ::/EFI ::/EFI/BOOT ::/loader ::/loader/entries
mcopy -i "$ESP" "$R/usr/lib/systemd/boot/efi/systemd-bootaa64.efi" ::/EFI/BOOT/BOOTAA64.EFI
mcopy -i "$ESP" "$WORK/loader.conf" ::/loader/loader.conf
mcopy -i "$ESP" "$WORK/ubuntu.conf" ::/loader/entries/ubuntu.conf
mcopy -i "$ESP" "$R/boot/Image" ::/Image
mcopy -i "$ESP" "$R/boot/initrd.img-$KVER" ::/initrd.img

echo "=== rootfs.img"
USED=$(du -sm --apparent-size "$R" | cut -f1)
IMG="$B/rootfs.img"
rm -f "$IMG"
truncate -s $(( USED * 13 / 10 + 1024 ))M "$IMG"
mke2fs -q -F -t ext4 -b 4096 -L otaroot -d "$R" "$IMG"
e2fsck -fy "$IMG" >/dev/null || [ $? -le 1 ]
# Shrink to fit; x-systemd.growfs grows it on first boot
resize2fs -M "$IMG"
e2fsck -fn "$IMG" >/dev/null || fail "rootfs.img not clean after resize"
rm -rf "$R"

echo "=== Pack"
mkdir -p "$OUT"
tar --sparse -C "$WORK" -cf - "$NAME" | zstd -T0 -12 > "$OUT/$NAME.qcomflash.tar.zst"
ls -l "$OUT/$NAME.qcomflash.tar.zst"
