# meta-oe builds neatvnc with no optional features at all, which does not work
# for weston's VNC backend: the backend always calls nvnc_enable_auth() with
# NVNC_AUTH_REQUIRE_AUTH, and neatvnc can only offer an authenticating
# security type when it is built with nettle (RSA-AES) or TLS (VeNCrypt). With
# neither it has nothing to offer and aborts the moment a client connects:
#
#   PANIC: Failed to satisfy requested security constraints
#
# nettle is the one that matters. It provides the RSA-AES security types,
# which authenticate and encrypt the session using a key neatvnc generates in
# memory at start-up -- so there is no certificate to create, install, renew
# or keep track of on the device. That is what lets the shipped default
# (VNC_TLS=off in /etc/default/remote-desktop) work.
#
# neatvnc 0.9.6 predates oe-core's nettle 4.0 and does not compile against it:
# <nettle/sha.h> was removed, and the EAX digest calls lost their length
# argument. Both are fixed upstream in neatvnc 1.x; the two commits backport
# cleanly on top of meta-oe's patch stack, along with the follow-up that fixes
# an argument mixup the second of them left in the WebSocket handshake.
#
# TLS stays enabled as well, so VeNCrypt X509Plain remains available for
# clients too old for RSA-AES (TigerVNC < 1.12, for instance). It only
# activates when someone sets VNC_TLS=on, which is when the certificate is
# generated -- nothing is written to the device otherwise.
#
# jpeg is cheap (libjpeg-turbo is already on the image) and enables the
# Tight/JPEG encodings, which cut bandwidth substantially on desktop content.
FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:append = " \
    file://0001-Use-nettle-hogweed-version-4.patch \
    file://0002-crypto-Remove-hash-digest-size-argument.patch \
    file://0003-stream-ws-handshake-Fix-crypto_hash_many-argument-mix.patch \
"

# meta-oe's recipe has no nettle knob, so declare one. gmp comes with it:
# neatvnc's meson checks for nettle, hogweed and gmp separately.
PACKAGECONFIG[nettle] = "-Dnettle=enabled,-Dnettle=disabled,nettle gmp"

PACKAGECONFIG:append = " nettle tls jpeg"
