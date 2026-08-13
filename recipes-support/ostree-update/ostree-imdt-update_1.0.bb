SUMMARY = "On-target OSTree pull/deploy helper for IMDT QCS8550 boards"
DESCRIPTION = "Ships the ostree-imdt-update script and its OSTree remote config. \
It pulls the latest commit from the configured HTTP remote and deploys it, with \
rollback via OSTree BLS boot counting under systemd-boot."

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

COMPATIBLE_MACHINE = "qcs8550"

SRC_URI = "file://ostree-imdt-update"
S = "${UNPACKDIR}"

# HTTP(S) URL of the OSTree repo, override per deployment. gpg-verify is off by
# default, set OSTREE_UPDATE_GPG_VERIFY = "true" and ship keys to enable it.
OSTREE_UPDATE_URL ?= "http://update.example.com/ostree"
OSTREE_UPDATE_REMOTE ?= "imdt"
OSTREE_UPDATE_GPG_VERIFY ?= "false"

OSTREE_OSNAME ?= "imdt"
OSTREE_BRANCHNAME ?= "${MACHINE}"

do_install() {
    install -D -m 0755 ${UNPACKDIR}/ostree-imdt-update \
        ${D}${sbindir}/ostree-imdt-update

    install -d ${D}${sysconfdir}/default
    cat > ${D}${sysconfdir}/default/ostree-imdt-update <<EOF
# Defaults for ostree-imdt-update (generated at build time).
OSTREE_REMOTE="${OSTREE_UPDATE_REMOTE}"
OSTREE_BRANCH="${OSTREE_BRANCHNAME}"
OSTREE_OSNAME="${OSTREE_OSNAME}"
EOF

    install -d ${D}${sysconfdir}/ostree/remotes.d
    cat > ${D}${sysconfdir}/ostree/remotes.d/${OSTREE_UPDATE_REMOTE}.conf <<EOF
[remote "${OSTREE_UPDATE_REMOTE}"]
url=${OSTREE_UPDATE_URL}
gpg-verify=${OSTREE_UPDATE_GPG_VERIFY}
EOF
}

FILES:${PN} += " \
    ${sysconfdir}/default/ostree-imdt-update \
    ${sysconfdir}/ostree/remotes.d/${OSTREE_UPDATE_REMOTE}.conf \
"

# ostree CLI for pull/deploy. Rollback is via systemd-boot BLS boot counting,
# so no libubootenv/fw_setenv dependency (unlike the U-Boot variant).
RDEPENDS:${PN} = "ostree"
