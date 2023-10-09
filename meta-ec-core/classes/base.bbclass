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

# Pre-build configuration output
BUILDCFG_HEADER = "Build Configuration${@" (mc:${BB_CURRENT_MC})" if d.getVar("BBMULTICONFIG") else ""}:"
BUILDCFG_VARS = "BB_VERSION DISTRO PLATFORM"
BUILDCFG_FUNCS = "buildcfg_vars get_layers_branch_rev"

def buildcfg_vars(d):
    statusvars = d.getVar('BUILDCFG_VARS').split()
    for var in statusvars:
        value = d.getVar(var)
        if value is not None:
            yield '%-20s = "%s"' % (var, value)

def base_get_metadata_git_branch(path, d):
    import bb.process

    try:
        rev, _ = bb.process.run('git rev-parse --abbrev-ref HEAD', cwd=path)
    except bb.process.ExecutionError:
        rev = '<unknown>'
    return rev.strip()

def base_get_metadata_git_revision(path, d):
    import bb.process

    try:
        rev, _ = bb.process.run('git rev-parse HEAD', cwd=path)
    except bb.process.ExecutionError:
        rev = '<unknown>'
    return rev.strip()

def get_layers_branch_rev(d):
    layers = (d.getVar("BBLAYERS") or "").split()
    layers_branch_rev = ["%-20s = \"%s:%s\"" % (os.path.basename(i), \
        base_get_metadata_git_branch(i, None).strip(), \
        base_get_metadata_git_revision(i, None)) \
            for i in layers]
    i = len(layers_branch_rev)-1
    p1 = layers_branch_rev[i].find("=")
    s1 = layers_branch_rev[i][p1:]
    while i > 0:
        p2 = layers_branch_rev[i-1].find("=")
        s2= layers_branch_rev[i-1][p2:]
        if s1 == s2:
            layers_branch_rev[i-1] = layers_branch_rev[i-1][0:p2]
            i -= 1
        else:
            i -= 1
            p1 = layers_branch_rev[i].find("=")
            s1= layers_branch_rev[i][p1:]
    return layers_branch_rev

addhandler base_eventhandler
base_eventhandler[eventmask] = "bb.event.BuildStarted"
python base_eventhandler() {
    import bb.runqueue
    if isinstance(e, bb.event.BuildStarted):
        d.setVar('BB_VERSION', bb.__version__)
        localdata = bb.data.createCopy(d)
        statuslines = []
        for func in localdata.getVar('BUILDCFG_FUNCS').split():
            g = globals()
            if func not in g:
                bb.warn("Build configuration function '%s' does not exist" % func)
            else:
                flines = g[func](localdata)
                if flines:
                    statuslines.extend(flines)

        statusheader = d.getVar('BUILDCFG_HEADER')
        if statusheader:
            bb.plain('\n%s\n%s\n' % (statusheader, '\n'.join(statuslines)))
}

EXPORT_FUNCTIONS do_fetch do_install do_configure do_build_recipe
