#!/bin/bash
# Install the desktop and the tools the Yocto images ship, run in the chroot.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -y upgrade

# The desktop and services
apt-get -y install \
    ubuntu-desktop-minimal \
    gnome-remote-desktop \
    adbd \
    snapd \
    openssh-server \
    network-manager \
    sudo \
    initramfs-tools \
    systemd-boot-efi \
    zstd

# Qualcomm remote processor services (fastrpc.sh builds FastRPC)
apt-get -y install \
    qrtr-tools \
    rmtfs \
    tqftpserv \
    protection-domain-mapper

# Same tools as the Yocto images
apt-get -y install \
    alsa-utils \
    alsa-ucm-conf \
    bluez \
    clinfo \
    device-tree-compiler \
    ethtool \
    gdb \
    glmark2-es2-wayland \
    gpiod \
    gstreamer1.0-libcamera \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-tools \
    i2c-tools \
    iperf3 \
    iw \
    kmscube \
    libcamera-tools \
    mesa-utils \
    mesa-vulkan-drivers \
    pciutils \
    rsync \
    strace \
    stress-ng \
    tcpdump \
    tpm2-tools \
    usbutils \
    v4l-utils \
    vulkan-tools \
    wpasupplicant
