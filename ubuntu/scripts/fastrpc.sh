#!/bin/bash
# Build Qualcomm's FastRPC userspace (libcdsprpc, cdsprpcd), which 26.04 does not package.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Same release as meta-qcom's fastrpc recipe
VER=1.0.8
REV=d247519650fe5cb16de6c78edaa95bcc4be25073
DEPS="git ca-certificates build-essential autoconf automake libtool pkg-config libbsd-dev libyaml-dev"

# acl for the setfacl in its udev rule
apt-get -y install libbsd0 libyaml-0-2 acl
# Only drop the build deps the image did not already have
NEW=$(for p in $DEPS; do dpkg -s "$p" >/dev/null 2>&1 || echo "$p"; done)
apt-get -y install --no-install-recommends $DEPS

src=$(mktemp -d /tmp/fastrpc.XXXXXX)
git clone -q --depth 1 --branch "v$VER" https://github.com/qualcomm/fastrpc.git "$src"
[ "$(git -C "$src" rev-parse HEAD)" = "$REV" ]

cd "$src"
./gitcompile --prefix=/usr \
    --with-systemdsystemunitdir=/usr/lib/systemd/system \
    --with-udevrulesdir=/usr/lib/udev/rules.d \
    --with-sysusersdir=/usr/lib/sysusers.d
make install
cd /
rm -rf "$src"

# The udev rule hands the device nodes to this group, and its units start from udev
getent group fastrpc >/dev/null || groupadd --system fastrpc
ldconfig

[ -z "$NEW" ] || apt-mark auto $NEW
apt-get -y autoremove --purge
