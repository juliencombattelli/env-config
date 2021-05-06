inherit logging
inherit utility-tasks

def pkg_providers_inc(d):
    pkg_providers = d.getVar('DISTRO_PKG_PROVIDERS', True)
    return "".join("recipes-core/pkg-providers/include/{}.inc ".format(p) for p in pkg_providers.split())

require ${@pkg_providers_inc(d)}

BB_DEFAULT_TASK ?= "build_recipe"

python base_do_register_for_installation() {
    bb.plain(f"Registering {d.getVar('PN')} for install")
    pn = d.getVar("PN")
    preferred_pkg_providers = d.getVar("PREFERRED_PKG_PROVIDERS_" + pn)
    distro_pkg_providers = d.getVar("DISTRO_PKG_PROVIDERS")
    pkg_providers = preferred_pkg_providers if preferred_pkg_providers is not None else \
                    distro_pkg_providers
    for pkg_provider in pkg_providers.split():
        # Use PKG_PROVIDER_<provider>_VERSION_PATTERN_<pkg> if exists, otherwise use the package name
        pkg_pattern = d.getVar("PKG_PROVIDER_{provider}_VERSION_PATTERN_{pkg}".format(provider=pkg_provider, pkg=pn))
        pattern = pkg_pattern if pkg_pattern is not None else \
                  "^{}$".format(pn)
        version = d.getVar("PREFERRED_PKG_VERSION_{pkg}".format(pkg=pn))
        found_pkg = globals()["pkg_provider_{}_search_package".format(pkg_provider)](d, pattern, version)
        if found_pkg:
            register_for_installation(d, found_pkg)
            return
}
addtask do_register_for_installation
do_register_for_installation[depends] = "pkg_providers:do_update"

# Fetch a package either by using a package manager if possible, or by downloading the sources
python base_do_fetch() {
    bb.plain(f"Fetching {d.getVar('PN')}")
    pn = d.getVar("PN")
    src_uri = (d.getVar("SRC_URI") or "").split()
    if len(src_uri) == 0:
        return
    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
        fetcher.download()
        fetcher.unpack(d.getVar('WORKDIR'))
    except bb.fetch2.BBFetchException as e:
        bb.fatal(str(e))
}
addtask do_fetch after do_register_for_installation

# Build a software whose source have been downloaded
python base_do_compile() {
    bb.plain(f"Compiling {d.getVar('PN')}")
}
addtask do_compile after do_fetch

# Install a software that has been built
python base_do_install() {
    bb.plain(f"Installing {d.getVar('PN')}")
}
addtask do_install after do_compile

# Configure an installed software
python base_do_configure() {
    bb.plain(f"Configure {d.getVar('PN')}")
}
addtask do_configure after do_install
do_configure[depends] = "pkg_providers:do_install_packages"

# Default task executed after all others
python base_do_build_recipe() {
}
addtask do_build_recipe after do_configure

EXPORT_FUNCTIONS do_register_for_installation do_fetch do_compile do_install do_configure