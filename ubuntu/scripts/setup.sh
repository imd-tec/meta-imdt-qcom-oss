#!/bin/bash
# Users, services and cleanup, run in the rootfs chroot.
set -euo pipefail

echo imdt-ubuntu > /etc/hostname
printf '127.0.0.1\tlocalhost\n127.0.1.1\timdt-ubuntu\n' > /etc/hosts

# Same password as the Yocto images
useradd -m -s /bin/bash -G sudo,adm,audio,video,render,plugdev,dialout,fastrpc ubuntu
echo 'root:oelinux123' | chpasswd
echo 'ubuntu:oelinux123' | chpasswd

# Auto-login never unlocks a password keyring, so give ubuntu an empty-password
# (plain text) login keyring for the desktop sharing RDP credentials
k=/home/ubuntu/.local/share/keyrings
mkdir -p "$k"
printf '[keyring]\ndisplay-name=Login\nctime=0\nmtime=0\nlock-on-idle=false\nlock-after=false\n' > "$k/login.keyring"
echo login > "$k/default"
chown -R ubuntu:ubuntu /home/ubuntu/.local
chmod 700 "$k"
chmod 600 "$k/login.keyring"

chmod 600 /etc/netplan/01-network-manager-all.yaml
mkdir -p /boot/efi /mnt/dtb

systemctl enable ssh-host-keys.service ssh.service NetworkManager.service adbd.service \
    gnome-remote-desktop.service imdt-enable-rdp.service
systemctl set-default graphical.target

# Per-board and per-device state is created on first boot
rm -f /etc/ssh/ssh_host_*
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id

apt-get clean
rm -rf /var/lib/apt/lists/* /var/tmp/*
