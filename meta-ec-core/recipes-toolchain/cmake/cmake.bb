DESCRIPTION = ""
PN = "cmake"
PV = "1"

SRC_URI = "file://cmake.sh"

inherit installable

do_configure() {
    mkdir -p "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp "${WORKDIR}"/cmake.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
