inherit logging
inherit utility-tasks

BB_DEFAULT_TASK ?= "build_recipe"

SRC_URI ?= ""

python base_do_fetch() {
    bb.plain("Fetching files for " + d.getVar('PN') + ".")
    src_uri = (d.getVar('SRC_URI') or "").split()
    fetcher = bb.fetch2.Fetch(src_uri, d)
    fetcher.download()
    rootdir = d.getVar('WORKDIR')
    fetcher.unpack(rootdir)
}
addtask do_fetch
# Add a dependency between this:do_fetch and other:do_build_recipe for every other recipe in DEPENDS
# TODO this is currently causing circular dependencies (ie. with zsh and oh-my-zsh)
# python() {
#     deps = ['{}:do_build_recipe'.format(pkg) for pkg in d.getVar('DEPENDS').split()]
#     if deps:
#         d.appendVarFlag('do_fetch', 'depends', ' '.join(deps))
# }

python base_do_install() {
    bb.plain("Installing " + d.getVar('PN') + ".")
}
addtask do_install after do_fetch

python base_do_configure() {
    bb.plain("Configuring " + d.getVar('PN') + ".")
}
addtask do_configure after do_install
do_configure[depends] = "base-files:do_configure"

python base_do_build_recipe() {
}
addtask do_build_recipe after do_configure

EXPORT_FUNCTIONS do_fetch do_install do_configure do_build_recipe
