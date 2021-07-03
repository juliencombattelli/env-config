def pkg_providers_inc(d):
    pkg_providers = d.getVar('DISTRO_PKG_PROVIDERS', True)
    return "".join("recipes-core/pkg-providers/include/{}.inc ".format(p) for p in pkg_providers.split())

require ${@pkg_providers_inc(d)}

DEPENDS += "${DISTRO_PKG_PROVIDERS}"

# Install the package with the appropriate package provider:
# Loop through PREFERRED_PKG_PROVIDERS_<pkg> if defined, DISTRO_PKG_PROVIDERS otherwise
#   Use PKG_PROVIDER_<provider>_PACKAGE_PATTERN_<pkg> if defined as pattern, <pkg> otherwise
#   Use PKG_PROVIDER_<provider>_PREFERRED_VERSION_<pkg> if defined as version specification, None otherwise
#   Call pkg_provider_<provider>_search_package function with pattern and version specification
#   If package found, install it and return
python installable_do_install() {
    bb.plain(f"Installing {d.getVar('PN')}")
    pn = d.getVar("PN")
    preferred_pkg_providers = d.getVar("PREFERRED_PKG_PROVIDERS_" + pn)
    distro_pkg_providers = d.getVar("DISTRO_PKG_PROVIDERS")
    pkg_providers = preferred_pkg_providers if preferred_pkg_providers is not None else distro_pkg_providers
    for pkg_provider in pkg_providers.split():
        pkg_pattern = d.getVar("PKG_PROVIDER_{provider}_PACKAGE_PATTERN_{pkg}".format(provider=pkg_provider, pkg=pn))
        pattern = pkg_pattern if pkg_pattern is not None else pn
        version = d.getVar("PREFERRED_PKG_VERSION_{pkg}".format(pkg=pn))
        search_package_func = "pkg_provider_{}_search_package".format(pkg_provider)
        bb.plain(f"Searching for {d.getVar('PN')} with {pkg_provider}")
        found_pkg, is_installed = globals()[search_package_func](d, "^{}$".format(pattern), version)
        if found_pkg:
            if is_installed:
                bb.plain(f"{found_pkg} already installed")
            else:
                bb.plain(f"Installing {found_pkg}")
                install_package_func = "pkg_provider_{}_install_packages".format(pkg_provider)
                globals()[install_package_func](d, found_pkg)
            d.setVar("PACKAGE_INSTALLED", True)
            return
}
addtask do_install before do_configure
do_install[deptask] = "do_update"

EXPORT_FUNCTIONS do_install 