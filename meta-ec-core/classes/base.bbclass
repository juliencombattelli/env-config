inherit logging
inherit utility-tasks

def pkg_providers_inc(d):
    pkg_providers = d.getVar('DISTRO_PKG_PROVIDERS', True)
    return "".join("recipes-pkg-provider/{provider}/{provider}.inc ".format(provider=p) for p in pkg_providers.split())

require ${@pkg_providers_inc(d)}

BB_DEFAULT_TASK ?= "configure"

DEPENDS += "${DISTRO_PKG_PROVIDERS}"

# Fetch from package manager
def fetch_from_pkg_mgr(d):
    pass

# Fetch from source
def fetch_from_src(d):
    src_uri = (d.getVar("SRC_URI") or "").split()
    if len(src_uri) == 0:
        return
    try:
        fetcher = bb.fetch2.Fetch(src_uri, d)
        fetcher.download()
        fetcher.unpack(d.getVar('WORKDIR'))
    except bb.fetch2.BBFetchException as e:
        bb.fatal(str(e))

# Fetch a package either by using a package manager if possible, or by downloading the sources
python base_do_fetch() {
    pn = d.getVar("PN")
    preferred_pkg_providers = d.getVar("PREFERRED_PKG_PROVIDERS_" + pn)
    distro_pkg_providers = d.getVar("DISTRO_PKG_PROVIDERS")
    pkg_providers = preferred_pkg_providers if preferred_pkg_providers is not None else \
                    distro_pkg_providers

    for pkg_provider in pkg_providers.split():
        # Use PKG_PROVIDER_<provider>_VERSION_PATTERN_<pkg> if exists, otherwise use the package name
        pkg_pattern = d.getVar("PKG_PROVIDER_{provider}_VERSION_PATTERN_{pkg}".format(provider=pkg_provider, pkg=pn))
        pattern = pkg_pattern if pkg_pattern is not None else \
                  pn
        pkg = globals()[pkg_provider + "_search_package"](d, pattern)
        # register it for installation if pkg found
        return

    # if no pkg_provider able to provide pkg
    # fetch_from_src(d)

    # bb.plain("distro_pkg_providers: " + distro_pkg_providers)
    # bb.plain("preferred_pkg_providers for " + pn + ": " + str(preferred_pkg_providers))
    # bb.plain("pkg_providers for " + pn + ": " + str(pkg_providers))

    bb.plain(f"Fetching {d.getVar('PN')}")
}
addtask do_fetch
do_fetch[deptask] = "do_update"

# Build a software whose source have been downloaded
python base_do_compile() {
    bb.plain(f"Compiling {d.getVar('PN')}")
}
addtask do_compile
do_compile[deptask] = "do_install_packages"

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

EXPORT_FUNCTIONS do_fetch do_compile do_install do_configure