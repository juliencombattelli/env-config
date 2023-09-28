inherit logging
inherit utility-tasks

# Python modules automatically imported
EC_IMPORTS += "os sys time re json"

def ec_import(d): # Based on Poky's oe_import()
    import sys

    bbpath = d.getVar("BBPATH").split(":")
    sys.path[0:0] = [os.path.join(dir, "lib") for dir in bbpath]

    def inject(name, value):
        """Make a python object accessible from the metadata"""
        if hasattr(bb.utils, "_context"):
            bb.utils._context[name] = value
        else:
            __builtins__[name] = value

    for toimport in d.getVar("EC_IMPORTS").split():
        try:
            imported = __import__(toimport)
            inject(toimport.split(".", 1)[0], imported)
        except AttributeError as e:
            bb.error("Error importing python modules: %s" % str(e))
    return ""

EC_IMPORTED := "${@ec_import(d)}"

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
# Add a dependency between this:do_fetch (first recipe) and other:do_build_recipe
# (last recipe) for every other recipes in DEPENDS
python() {
    deps = ['{}:do_build_recipe'.format(pkg) for pkg in d.getVar('DEPENDS').split()]
    if deps:
        d.appendVarFlag('do_fetch', 'depends', ' '.join(deps))
}

python base_do_install() {
    bb.plain("Installing " + d.getVar('PN') + ".")
}
addtask do_install after do_fetch
do_install[dirs] = "${B}"

python base_do_configure() {
    bb.plain("Configuring " + d.getVar('PN') + ".")
}
addtask do_configure after do_install
do_configure[dirs] = "${B}"
do_configure[depends] = "base-files:do_configure"

python base_do_build_recipe() {
}
addtask do_build_recipe after do_configure

EXPORT_FUNCTIONS do_fetch do_install do_configure do_build_recipe
