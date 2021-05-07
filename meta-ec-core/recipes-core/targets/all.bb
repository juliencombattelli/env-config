DESCRIPTION = "Install and deploy the configuration of all packages in PKG_INSTALL"
PN = "all"
PV = "1"

DEPENDS += "${PKG_INSTALL}"

do_build_recipe[deptask] += "do_configure"

do_install[noexec] = "1"
do_configure[noexec] = "1"