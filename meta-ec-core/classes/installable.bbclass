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
#   - pkg: the package name to be installed
#   - version: the package version (or None if irrelevant for installation)
# Returns:
#   - whether the installation failed or succeeded

def pkg_providers_inc(d):
    '''
    Return a list of space separated paths to the currently used package providers.
    '''
    pkg_providers = d.getVar('DISTRO_PKG_PROVIDERS', True)
    return "".join("recipes-core/pkg-providers/api/{}.inc ".format(p) for p in pkg_providers.split())

require ${@pkg_providers_inc(d)}

DEPENDS += "${DISTRO_PKG_PROVIDERS}"

# Install the package with the appropriate package provider:
# Loop through PREFERRED_PKG_PROVIDERS_<pkg> if defined, DISTRO_PKG_PROVIDERS otherwise
#   Use PKG_PROVIDER_<provider>_PACKAGE_PATTERN_<pkg> if defined as pattern, <pkg> otherwise
#   Use PKG_PROVIDER_<provider>_PREFERRED_VERSION_<pkg> if defined as version specification, None otherwise
#   Call pkg_provider_<provider>_search_package function with pattern and version specification
#   If package found, install it and return
#   If installation is successful, PACKAGE_INSTALLED variable is set to True
python installable_do_install() {

    def enabled_package_providers(d, pkg):
        pkg_providers = (d.getVar("PREFERRED_PKG_PROVIDERS_" + pn) or d.getVar("DISTRO_PKG_PROVIDERS") or "").split()
        excluded_pkg_providers = (d.getVar("EXCLUDELIST_PKG_PROVIDERS_{pkg}".format(pkg=pn)) or "").split()
        return [provider for provider in pkg_providers if provider not in excluded_pkg_providers]

    def search_package(d, pkg_provider, pkg, version_spec):
        pkg_pattern = d.getVar("PKG_PROVIDER_{provider}_PACKAGE_PATTERN_{pkg}".format(provider=pkg_provider, pkg=pkg))
        pattern = pkg_pattern if pkg_pattern is not None else pkg
        pattern_is_whole_word = False if pkg_pattern is not None else True # If using ${PN} as pattern, then search in wholeword mode
        search_package_func = "pkg_provider_{}_search_package".format(pkg_provider)
        bb.plain("Searching for " + pkg + " with " + pkg_provider)
        found_pkg, found_version, is_installed = globals()[search_package_func](d, pattern, pattern_is_whole_word, version)
        return found_pkg, found_version, is_installed

    def install_package(d, pkg_provider, found_pkg, version):
        install_package_func = "pkg_provider_{}_install_packages".format(pkg_provider)
        globals()[install_package_func](d, found_pkg, version)

    pn = d.getVar("PN")
    version = d.getVar("PREFERRED_PKG_VERSION_" + pn)
    pkg_providers = enabled_package_providers(d, pn)

    bb.plain("Installing " + pn + ".")

    is_installed = False
    for pkg_provider in pkg_providers:
        found_pkg, found_version, is_installed = search_package(d, pkg_provider, pn, version)
        if found_pkg:
            bb.plain("Found candidate " + found_pkg + " for package " + pn + " using " + pkg_provider)
            if is_installed:
                bb.plain(found_pkg + " already installed.")
            else:
                bb.plain("Installing " + found_pkg + ".")
                install_package(d, pkg_provider, found_pkg, version)
            d.setVar("PACKAGE_INSTALLED", True)
            return
        else:
            pattern = "" if pkg_pattern is None else " (pattern: `{}`)".format(pkg_pattern)
            bb.warn("Unable to install package `{}`{} with package provider `{}`".format(pn, pattern, pkg_provider))
    if not is_installed:
        bb.error("Unable to install package `" + pn + "` with any package provider")
}
addtask do_install before do_configure
do_install[deptask] = "do_update"

EXPORT_FUNCTIONS do_install

# Exclude pip from the considered package providers by default as pypi.org is
# beyond anybody's control: anyone can upload a package called `make` completely
# unrelated to build systems (oups, this has been done...)
# Recipes must explicitly enable pip as a pkg provider by using:
# EXCLUDELIST_PKG_PROVIDERS_${PN}:remove = "pip"
# It is recommended to do this in a distro file where the considered distro does
# not have other way to provide the package.
EXCLUDELIST_PKG_PROVIDERS_${PN} = "pip"
