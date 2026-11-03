# Enable the VNC backend so the board can be used with no display attached.
# See docs/remote-desktop.md.
#
# PACKAGECONFIG[vnc] pulls in neatvnc and libpam, and weston then also
# installs /etc/pam.d/weston-remote-access itself (pam/meson.build), which is
# the PAM service the VNC backend authenticates against. Nothing else here
# needs to ship a PAM configuration.
PACKAGECONFIG:append = " vnc"
