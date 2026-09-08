#!/bin/bash
# Build a plain Ubuntu Server rootfs image for the "otaroot" partition.
#
# Downloads the Ubuntu Server live ISO, extracts its squashfs (base +
# minimal overlay), sets the root password, and packs it into an ext4
# image labelled "otaroot" — a drop-in replacement for the "rootfs.img"
# in a qcom-distro (non-OTA) build's qcomflash output. See the README's
# "Flashing a plain Ubuntu rootfs" section for the full flashing steps.
set -euo pipefail

URL="https://cdimage.ubuntu.com/releases/26.04/release/ubuntu-26.04.1-live-server-arm64.iso"
SIZE="6G"
LABEL="otaroot"
OUT="rootfs.img"
ROOT_PASSWORD="oelinux123"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

ISO="$WORK/$(basename "$URL")"
curl -L -o "$ISO" "$URL"
curl -sL "${URL%/*}/SHA256SUMS" -o "$WORK/SHA256SUMS"
(cd "$WORK" && grep "$(basename "$URL")" SHA256SUMS | sha256sum -c -)

7z x -y "$ISO" -o"$WORK/squash" casper/ubuntu-server-minimal.squashfs casper/ubuntu-server-minimal.ubuntu-server.squashfs >/dev/null

mkdir -p "$WORK/rootfs" "$WORK/overlay"
fakeroot -s "$WORK/fakeroot.state" -- bash -c "
  unsquashfs -f -d '$WORK/rootfs' '$WORK/squash/casper/ubuntu-server-minimal.squashfs'
  unsquashfs -f -d '$WORK/overlay' '$WORK/squash/casper/ubuntu-server-minimal.ubuntu-server.squashfs'
  # Drop bytecode caches from both trees first: the minimal and server
  # squashfs disagree on file type (dir vs file) at some __pycache__
  # paths, which cp -a refuses to merge. They regenerate on first run.
  find '$WORK/rootfs' '$WORK/overlay' -name '__pycache__' -prune -exec rm -rf {} +
  cp -a '$WORK/overlay/.' '$WORK/rootfs/'
"

# Default root password: oelinux123 (matches the Yocto images).
HASH=$(openssl passwd -6 -salt "$(openssl rand -hex 4)" "$ROOT_PASSWORD")
DAYS=$(( $(date +%s) / 86400 ))
sed -i "s#^root:[^:]*:[^:]*:#root:${HASH//\#/\\#}:${DAYS}:#" "$WORK/rootfs/etc/shadow"

truncate -s "$SIZE" "$OUT"
fakeroot -i "$WORK/fakeroot.state" -s "$WORK/fakeroot.state" -- mke2fs -F -t ext4 -L "$LABEL" -d "$WORK/rootfs" "$OUT"

e2fsck -fy "$OUT" || true
