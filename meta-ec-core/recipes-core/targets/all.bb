DESCRIPTION = "Install and deploy the configuration of all packages in PKG_INSTALL"
PN = "all"
PV = "1"

DEPENDS += "${PKG_INSTALL}"

do_install[noexec] = "1"
