# On self-hosted CI runners (uid/gid 1000), libtiff 4.7.1 can leave installed
# files owned by the build user, tripping host-user-contaminated in do_package_qa.
do_install:append() {
    chown -R root:root ${D}
}
