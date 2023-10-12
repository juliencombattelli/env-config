DESCRIPTION = "Install and deploy the configuration of all packages in PKG_INSTALL"
PN = "all"
PV = "1"

DEPENDS += "${PKG_INSTALL}"

do_complete[deptask] += "do_configure"

do_install[noexec] = "1"

do_configure() {
    # Replace all occurences of @EC_TARGET_INSTALL_DIR@ with the real install path in install directory
    find ${EC_TARGET_INSTALL_DIR} -type f -exec sed -i "s|@EC_TARGET_INSTALL_DIR@|${EC_TARGET_INSTALL_DIR}|g" {} +
}
