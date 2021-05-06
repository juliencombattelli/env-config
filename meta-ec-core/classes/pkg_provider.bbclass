# Base class for all pkg_providers

# TODO rework
# Remove this class and create pkg_providers recipe from this class
# do_update and do_install_packages should loop on all DISTRO_PKG_PROVIDERS
# and call the corresponding APIs defined in <pkg_provider>.inc

DEPENDS += "${PKG_INSTALL}"

python pkg_provider_do_update() {
    bb.plain(f"Updating pkg-provider {d.getVar('PN')}")
}
addtask do_update

python pkg_provider_do_install_packages() {
    bb.plain(f"Installing packages using pkg-provider {d.getVar('PN')}")
}
addtask do_install_packages
do_install_packages[deptask] += "do_fetch"

EXPORT_FUNCTIONS do_update do_install_packages

do_fetch[noexec] = "1"
do_compile[noexec] = "1"
do_configure[noexec] = "1"