# Remote desktop

The board can be used with no display attached — a full desktop over VNC, with
keyboard and mouse. It is a service of its own, so it behaves like the VNC
server on a desktop Linux machine: start it, stop it, disable it, and nothing
else on the system is affected.

It is enabled by default, so a board that boots with nothing plugged into it is
reachable straight away.

## Quick start

```sh
passwd weston                       # once, on the board: set the login password
vncviewer <board-ip>:5900           # from your PC; log in as user 'weston'
```

No certificate to install and nothing written to the board beyond that
password. The client has to support **RSA-AES** (TigerVNC 1.12 and later, for
instance); see [Encryption](#encryption) for older clients.

## Turning it on and off

```sh
systemctl status remote-desktop
systemctl stop remote-desktop            # this session only
systemctl disable --now remote-desktop   # and do not start it at boot
systemctl enable --now remote-desktop    # back on
```

`weston.service` is never involved. Starting or stopping the remote desktop
does not disturb the local display, and nothing needs restarting to switch
between them.

## Configuration

`/etc/default/remote-desktop` holds one variable, passed to Weston as-is:

```sh
REMOTE_DESKTOP_ARGS="--width=1920 --height=1080 --port=5900 --disable-transport-layer-security"
```

Change the resolution or port there and `systemctl restart remote-desktop`.
Any option from `weston(1)` or `weston-vnc(7)` can go in the same variable.

## Logging in

The VNC backend authenticates through PAM (`/etc/pam.d/weston-remote-access`,
shipped by weston) and **only accepts the user Weston runs as**, which is
`weston` — it compares the supplied username's uid against its own and rejects
anything else, `root` included.

That is the same session a locally attached keyboard would give, so it is not a
VNC restriction: applications run unprivileged, and a root shell is `su -` in a
terminal on the desktop. Set the password with `passwd weston`.

## Encryption

Sessions are authenticated and encrypted either way; the setting only chooses
how, and the default keeps nothing on the device.

**RSA-AES (default).** neatvnc generates an RSA key in memory when the service
starts and never writes it anywhere, so there is nothing to install, renew,
back up or clean up. A client that pins the key sees a new fingerprint after a
restart, and the client must speak RSA-AES (TigerVNC ≥ 1.12; not noVNC or
macOS Screen Sharing).

**TLS (VeNCrypt X509Plain).** For older clients. Remove
`--disable-transport-layer-security` from `REMOTE_DESKTOP_ARGS` and add
`--vnc-tls-cert=` and `--vnc-tls-key=` pointing at a certificate and key
readable by the `weston` user. Weston's own name for the first case oversells
it: the session is still encrypted, just without a certificate.

The service listens on all interfaces. On an untrusted network, either
firewall the port and come in through an SSH tunnel
(`ssh -L 5900:localhost:5900 root@<board>`), or use TLS with a certificate from
a CA your clients trust.

## It is a second desktop, not a copy of the screen

The remote desktop is independent of whatever is on the local display, exactly
like `vncserver` on a PC: two desktops, each with its own applications and its
own keyboard and mouse. Connecting over VNC does not show, or take over, the
session on the monitor.

## How it is put together

| Piece | Where |
|---|---|
| VNC backend, PAM service file | weston's `vnc` PACKAGECONFIG — `recipes-graphics/wayland/weston_%.bbappend` |
| aml 1.x fix for weston 15.x | `recipes-graphics/wayland/weston/0001-backend-vnc-build-against-aml1.patch` |
| RSA-AES + TLS + JPEG in neatvnc | `recipes-graphics/neatvnc/neatvnc_%.bbappend` |
| The service and its configuration | `recipes-graphics/remote-desktop/imdt-remote-desktop_1.0.bb` |

The service runs as `weston` with its own `XDG_RUNTIME_DIR` (`RuntimeDirectory=`)
and its own Wayland socket, and needs no VT, no seat and no root: it renders
through the GPU's render node while the local compositor keeps DRM master.

Only the two multimedia images install it; the minimal image has no Weston.

Two notes on the dependency versions, both of which the bbappends deal with:

- Weston 15.0.1 wants aml 0.3.x, but meta-openembedded only carries aml 1.0.0
  (pkg-config module `aml1`, renamed loop accessors), and its neatvnc is
  already patched to use it. Weston 16.0.0 asks for `aml1` natively, so the
  patch should be **deleted** when oe-core upgrades weston — the build fails
  loudly if it is not.
- meta-oe builds neatvnc with no optional features, which cannot work: the
  backend always requires authentication, and neatvnc can only offer an
  authenticating security type when built with nettle (RSA-AES) or TLS
  (VeNCrypt). The bbappend enables `nettle tls jpeg` and backports the two
  upstream commits that make neatvnc 0.9.6 build against oe-core's nettle 4.0.

## Limitations

- Only the multimedia images have it. On the QCS6490 SBC, which currently has
  only a minimal image, there is no remote desktop.
- The local display is not mirrored — see above.
- No browser client: reaching the desktop from a browser needs noVNC and
  websockify, which are not installed. noVNC also needs the TLS option, as it
  does not support RSA-AES.
- On a board with no display attached, `weston.service` still runs a compositor
  with no output. It is harmless; `systemctl disable weston` is an option for
  headless deployments.
