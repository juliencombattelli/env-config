DESCRIPTION = ""
PN = "cmake"
PV = "1"

SRC_URI += "file://cmake.sh"

inherit installable

# Install at least CMake 3.11 to get FetchContent
PREFERRED_PKG_VERSION_cmake = ">=3.11"

do_configure() {
    cp "${WORKDIR}"/cmake.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
