# Package provider Python API
#
# def pkg_provider_<provider>_search_package(d, pkg_pattern, is_whole_word, version)
# Takes the following parameters:
#   - d: BitBake's global data dictionnary
#   - pkg_pattern: A pattern identifying the package
#       The syntax depends on the provider
#   - is_whole_word: whether pattern is the exact package name
#       Usefull for provider supporting only regexes for patterns
#   - version: the version of the package to search for
# Returns a tuple with:
#   - the package name found
#   - its version (or None if irrelevant for installation)
#   - whether it is installed or not
# Knowing that the package is already installed is essentially an optimisation. However it could be
# usefull for package managers that do not support install queries for already installed packages.
#
# def pkg_provider_<provider>_install_package(d, pkg, version)
# Takes the following parameters:
#   - d: BitBake's global data dictionnary
#   - the package name to be installed
#   - the package version (or None if irrelevant for installation)
# Returns:
#   - whether the installation failed or succeeded

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
    bb.plain("Installing " + d.getVar('PN') + ".")
    pn = d.getVar("PN")
    preferred_pkg_providers = d.getVar("PREFERRED_PKG_PROVIDERS_" + pn)
    distro_pkg_providers = d.getVar("DISTRO_PKG_PROVIDERS")
    pkg_providers = preferred_pkg_providers if preferred_pkg_providers is not None else distro_pkg_providers
    is_installed = False
    for pkg_provider in pkg_providers.split():
        pkg_pattern = d.getVar("PKG_PROVIDER_{provider}_PACKAGE_PATTERN_{pkg}".format(provider=pkg_provider, pkg=pn))
        pattern = pkg_pattern if pkg_pattern is not None else pn
        pattern_is_whole_word = False if pkg_pattern is not None else True # If using ${PN} as pattern, then search in wholeword mode
        version = d.getVar("PREFERRED_PKG_VERSION_{pkg}".format(pkg=pn))
        search_package_func = "pkg_provider_{}_search_package".format(pkg_provider)
        bb.plain("Searching for " + d.getVar('PN') + " with " + pkg_provider)
        found_pkg, found_version, is_installed = globals()[search_package_func](d, pattern, pattern_is_whole_word, version)
        if found_pkg:
            bb.plain("Found candidate " + found_pkg + " for package " + d.getVar('PN') + " using " + pkg_provider)
            if is_installed:
                bb.plain(found_pkg + " already installed.")
            else:
                bb.plain("Installing " + found_pkg + ".")
                install_package_func = "pkg_provider_{}_install_packages".format(pkg_provider)
                globals()[install_package_func](d, found_pkg, version)
            d.setVar("PACKAGE_INSTALLED", True)
            return
        else:
            pattern = "" if pkg_pattern is None else " (pattern: `{}`)".format(pkg_pattern)
            bb.warn("Unable to install package `{}`{} with package provider `{}`".format(d.getVar('PN'), pattern, pkg_provider))
    if not is_installed:
        bb.error("Unable to install package `" + d.getVar('PN') + "` with any package provider")
}
addtask do_install before do_configure
do_install[deptask] = "do_update"

EXPORT_FUNCTIONS do_install
