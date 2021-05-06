DESCRIPTION = "Run update and install operations for all package providers in DISTRO_PKG_PROVIDERS"
PN = "pkg_providers"
PV = "1"

DEPENDS += "${PKG_INSTALL}"

python do_update() {
    bb.plain(f"Updating package providers")
    distro_pkg_providers = d.getVar("DISTRO_PKG_PROVIDERS")
    for provider in distro_pkg_providers.split():
        globals()["pkg_provider_{}_update".format(provider)](d)
}
addtask do_update

python do_install_packages() {
    bb.plain(f"Installing packages")
    distro_pkg_providers = d.getVar("DISTRO_PKG_PROVIDERS")
    for provider in distro_pkg_providers.split():
        globals()["pkg_provider_{}_install_packages".format(provider)](d)
}
addtask do_install_packages
do_install_packages[deptask] += "do_register_for_installation"

do_fetch[noexec] = "1"
do_compile[noexec] = "1"
do_configure[noexec] = "1"