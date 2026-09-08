# Enable the VNC backend so the board can be used with no display attached.
# See docs/remote-desktop.md.
#
# PACKAGECONFIG[vnc] pulls in neatvnc and libpam, and weston then also
# installs /etc/pam.d/weston-remote-access itself (pam/meson.build), which is
# the PAM service the VNC backend authenticates against. Nothing else here
# needs to ship a PAM configuration.
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# weston 15.x only: adapt the VNC backend to aml 1.x. Remove together with the
# patch when oe-core moves to weston >= 16 (it wants aml1 natively).
SRC_URI:append = " file://0001-backend-vnc-build-against-aml1.patch"

PACKAGECONFIG:append = " vnc"
