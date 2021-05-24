inherit logging
inherit utility-tasks

BB_DEFAULT_TASK ?= "build_recipe"

SRC_URI ?= ""

python base_do_fetch() {
    bb.plain(f"Fetching files for {d.getVar('PN')}")
    src_uri = (d.getVar('SRC_URI') or "").split()
    fetcher = bb.fetch2.Fetch(src_uri, d)
    fetcher.download()
    rootdir = d.getVar('WORKDIR')
    fetcher.unpack(rootdir)
}
addtask do_fetch

python base_do_install() {
    bb.plain(f"Installing {d.getVar('PN')}")
}
addtask do_install after do_fetch

python base_do_configure() {
    bb.plain(f"Configuring {d.getVar('PN')}")
}
addtask do_configure after do_install
do_configure[depends] = "base-files:do_configure"

python base_do_build_recipe() {
}
addtask do_build_recipe after do_configure

EXPORT_FUNCTIONS do_fetch do_install do_configure do_build_recipe