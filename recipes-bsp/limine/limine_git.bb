SUMMARY = "Limine Bootloader for AArch64"
DESCRIPTION = "Limine is a modern, feature-rich bootloader for x86_64 and AArch64 platforms, designed to be simple to use and highly customizable."
LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://COPYING;md5=d6614d6c570b65c910b41b9ab26973d9"
SRC_URI = " \
    git://github.com/Limine-Bootloader/Limine.git;protocol=https;branch=v10.x \
"
SRCREV = "8331af0d65f5a776ece0aa46b1d8122ea4afb07f"

inherit autotools deploy

EXTRA_OECONF = "--enable-uefi-aarch64 CC_FOR_TARGET='${CC} ${CFLAGS}' LD_FOR_TARGET='${LD}' OBJCOPY_FOR_TARGET='${OBJCOPY}' OBJDUMP_FOR_TARGET='${OBJDUMP}' READELF_FOR_TARGET='${READELF}'"
#grep, sed, find, awk, gzip, nasm, mtools are used in the build process
DEPENDS:append = " \
    coreutils-native \
    dtc-native \
    mtools-native \
    nasm-native \
"
RDEPENDS:${PN}:append = " limine-config"

FILES:${PN}:append = " /boot/"

do_configure:prepend() {
    cd ${S} && \
    ./bootstrap
}

do_compile() {
    cd ${S} && \
    oe_runmake  -f ${S}/GNUmakefile
}

do_install() {
	install -d ${D}/boot
	install -d ${D}/boot/EFI
	install -d ${D}/boot/EFI/BOOT
	install ${S}/bin/BOOTAA64.EFI  ${D}/boot/EFI/BOOT/
}

do_deploy () {
    # Deploy the built EFI binary to the deploy directory for use in the image recipe
	install ${S}/bin/BOOTAA64.EFI ${DEPLOYDIR}
}

addtask deploy before do_build after do_compile
