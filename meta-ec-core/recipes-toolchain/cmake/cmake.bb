DESCRIPTION = ""
PN = "cmake"
PV = "1"

SRC_URI += "file://cmake.sh"

inherit installable

EXCLUDELIST_PKG_PROVIDERS_${PN}:remove = "pip"

do_configure() {
    cp "${WORKDIR}"/cmake.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
