DESCRIPTION = "Install and deploy the configuration of all packages in PKG_INSTALL"
PN = "all"
PV = "1"

DEPENDS += "${PKG_INSTALL}"

do_build_recipe[deptask] += "do_configure"

do_fetch[noexec] = "1"
do_compile[noexec] = "1"
do_configure[noexec] = "1"