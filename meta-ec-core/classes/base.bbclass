inherit logging
inherit utility-tasks

BB_DEFAULT_TASK ?= "configure"

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

    bb.plain("distro_pkg_providers: " + distro_pkg_providers)
    bb.plain("preferred_pkg_providers for " + pn + ": " + str(preferred_pkg_providers))
    bb.plain("pkg_providers for " + pn + ": " + str(pkg_providers))
}
addtask do_fetch
do_fetch[nostamp] = "1"

# [deprecated] Install a software locally
python base_do_install() {
    bb.plain(f"Install {d.getVar('PN')}")
}
addtask do_install

# Configure and installed software
python base_do_configure() {
    bb.plain(f"Configure {d.getVar('PN')}")
}
addtask do_configure after do_install do_fetch
do_configure[nostamp] = "1"

EXPORT_FUNCTIONS do_install do_configure do_fetch