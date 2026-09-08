SUMMARY = "Remote desktop over VNC, as a service of its own"
DESCRIPTION = "Makes the board usable with no display attached, keyboard and \
mouse included. Runs a second Weston instance whose display is the VNC \
connection, so it is an ordinary service: start, stop, enable or disable it \
without touching weston.service or whatever is on the local display. The VNC \
backend comes from weston's 'vnc' PACKAGECONFIG, enabled in the weston \
bbappend, and carries pointer and keyboard input with it."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://remote-desktop.service \
    file://remote-desktop \
"

S = "${UNPACKDIR}"

inherit systemd features_check

# Weston, and therefore its VNC backend, needs both.
REQUIRED_DISTRO_FEATURES = "wayland pam"

# Enabled by default: a board that boots with no display attached should be
# reachable without anyone having to enable anything first.
SYSTEMD_SERVICE:${PN} = "remote-desktop.service"
SYSTEMD_AUTO_ENABLE:${PN} = "enable"

do_install() {
    install -D -m 0644 ${UNPACKDIR}/remote-desktop.service \
        ${D}${systemd_system_unitdir}/remote-desktop.service

    install -D -m 0644 ${UNPACKDIR}/remote-desktop \
        ${D}${sysconfdir}/default/remote-desktop
}

# ${sysconfdir} is in the default FILES; the systemd unit directory is not.
FILES:${PN} += "${systemd_system_unitdir}/remote-desktop.service"

# weston provides the compositor and its VNC backend, plus the
# /etc/pam.d/weston-remote-access the backend authenticates against;
# weston-init creates the 'weston' user the service runs as.
RDEPENDS:${PN} = "weston weston-init"

CONFFILES:${PN} = "${sysconfdir}/default/remote-desktop"
