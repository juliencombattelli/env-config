DESCRIPTION = ""
PN = "cmake"
PV = "1"

SRC_URI = "file://cmake.sh"

inherit installable

do_configure() {
    cp "${WORKDIR}"/cmake.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
