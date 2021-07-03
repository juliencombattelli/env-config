DESCRIPTION = ""
PN = "base-files"
PV = "1"

FILESPATH_prepend := "${THISDIR}:"

SRC_URI = "file://files"

do_configure() {
    mkdir -p "${EC_TARGET_INSTALL_DIR}"
    cp -r "${WORKDIR}"/files/. "${EC_TARGET_INSTALL_DIR}"
    find "${EC_TARGET_INSTALL_DIR}" -exec sed -i "s|@EC_TARGET_INSTALL_DIR@|${EC_TARGET_INSTALL_DIR}|g" {} \;
}
