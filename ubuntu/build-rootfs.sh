#!/bin/bash
# Build the generic Ubuntu desktop rootfs with debos, in its container.
#
# Usage: ubuntu/build-rootfs.sh <outdir>
# Writes <outdir>/ubuntu-26.04-desktop-arm64.tar.zst. On a non-arm64 host
# the chroot steps run through qemu binfmt and are much slower.
set -euo pipefail

HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(mkdir -p "$1" && cd "$1" && pwd)
BASE_URL="https://cdimage.ubuntu.com/ubuntu-base/releases/26.04/release"
BASE="ubuntu-base-26.04.1-base-arm64.tar.gz"
DEBOS_IMAGE="${DEBOS_IMAGE:-ghcr.io/go-debos/debos:latest}"

cd "$HERE"
if [ ! -f "$BASE" ]; then
    curl -fL -o "$BASE.tmp" "$BASE_URL/$BASE"
    mv "$BASE.tmp" "$BASE"
fi
curl -fsL "$BASE_URL/SHA256SUMS" | grep " \*$BASE\$" | sed 's/ \*/  /' | sha256sum -c -

docker run --rm --privileged --tmpfs /dev/shm:exec \
    -v /dev:/dev -v "$HERE:/recipes" -v "$OUT:/artifacts" -w /artifacts \
    "$DEBOS_IMAGE" --disable-fakemachine --artifactdir /artifacts \
    -t base:"$BASE" /recipes/imdt-ubuntu.yaml
