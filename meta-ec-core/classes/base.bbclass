inherit logging
inherit utility-tasks

################################################################################
### Import python modules and make them available for all recipes.
################################################################################

EC_IMPORTS += "os sys time re json ec.utils ec.siginfo"

def ec_import(d): # Based on Poky's oe_import()
    import sys
    import site

    bbpath = d.getVar("BBPATH").split(":")
    sys.path[0:0] = [os.path.join(dir, "lib") for dir in bbpath]
    # Add the user site packages directory to sys.path in case pip is not
    # already installed (needed for packages installed using pip and used in
    # recipes, like packaging)
    sys.path.append(site.getusersitepackages())

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

################################################################################
### Operations on all tasks
################################################################################

# Enable network capabilities for all tasks by default
# The current implementation changes the current uid/gid, leaving sudo unusable
python() {
    for e in bb.data.keys(d):
        if d.getVarFlag(e, "task", False):
            d.setVarFlag(e, "network", "1")
}

################################################################################
### Task start (first task executed for a given recipe).
################################################################################

# This task is just a placeholder for dependency handling
# Logic is added using postfuncs variable flag
python base_do_start() {
}
addtask do_start

# Build dependencies
# Task this:do_start may run only after all other:do_complete tasks for all
# recipes in DEPENDS have finished
python() {
    deps = ['{}:do_complete'.format(pkg) for pkg in d.getVar('DEPENDS').split()]
    if deps:
        d.appendVarFlag('do_start', 'depends', ' '.join(deps))
}

prepare_ec_target_install_dir() {
    mkdir -p "${EC_TARGET_INSTALL_DIR}"/backup/
    mkdir -p "${EC_TARGET_INSTALL_DIR}"/bin/
    mkdir -p "${EC_TARGET_INSTALL_DIR}"/etc/
    mkdir -p "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    mkdir -p "${EC_TARGET_INSTALL_DIR}"/share/
}

do_start[postfuncs] += "prepare_ec_target_install_dir"

# Emit a warning for recipes having EC_DEPRECATED set
# TODO add doc about EC_DEPRECATED
python warn_if_ec_deprecated() {
    ec_deprecated = d.getVar('EC_DEPRECATED')
    if ec_deprecated is not None:
        bb.warn("This recipe is deprecated. Reason: " + ec_deprecated)
}

do_start[postfuncs] += "warn_if_ec_deprecated"

################################################################################
### Task fetch (fetch files from SCR_URI).
################################################################################

python base_do_fetch() {
    bb.plain("Fetching files for " + d.getVar('PN') + ".")
    src_uri = (d.getVar('SRC_URI') or "").split()
    fetcher = bb.fetch2.Fetch(src_uri, d)
    fetcher.download()
    rootdir = d.getVar('WORKDIR')
    fetcher.unpack(rootdir)
}
addtask do_fetch after do_start

################################################################################
### Task install (install the package content into the filesystem).
################################################################################

python base_do_install() {
    bb.plain("Installing " + d.getVar('PN') + ".")
}
addtask do_install after do_fetch
do_install[dirs] = "${B}"

################################################################################
### Task configure (deploy and apply the package configuration).
################################################################################

python base_do_configure() {
    bb.plain("Configuring " + d.getVar('PN') + ".")
}
addtask do_configure after do_install
do_configure[dirs] = "${B}"

################################################################################
### Task complete (last task executed for a given recipe).
################################################################################

# The main task is just a placeholder for dependency handling
# Logic is added using prefuncs variable flag
python base_do_complete() {
}
addtask do_complete after do_configure

# Runtime dependencies
# Task this:do_complete may run only after all other:do_complete tasks for all
# recipes in RDEPENDS have finished
python() {
    deps = ['{}:do_complete'.format(pkg) for pkg in d.getVar('RDEPENDS').split()]
    if deps:
        d.appendVarFlag('do_complete', 'rdepends', ' '.join(deps))
}

replace_ec_target_install_dir() {
    find ${EC_TARGET_INSTALL_DIR} -type f -exec sed -i "s|@EC_TARGET_INSTALL_DIR@|${EC_TARGET_INSTALL_DIR}|g" {} +
}

do_complete[prefuncs] += "replace_ec_target_install_dir"

################################################################################
### Export base class functions.
################################################################################

EXPORT_FUNCTIONS do_start do_fetch do_install do_configure do_complete

################################################################################
### Pre-build configuration output.
################################################################################

BUILDCFG_HEADER = "Build Configuration${@" (mc:${BB_CURRENT_MC})" if d.getVar("BBMULTICONFIG") else ""}:"
BUILDCFG_VARS = "BB_VERSION DISTRO PLATFORM DISABLE_SUDO DISABLE_SUDO_FORCED"
# Do not include DISABLE_PKG_PROVIDERS_UPDATE in BUILDCFG_VARS as this option
# targets developers only
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

def display_ec_status(d):
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

################################################################################
### Pre-build event handlers.
################################################################################

addhandler base_eventhandler
base_eventhandler[eventmask] = "bb.event.BuildStarted"
python base_eventhandler() {
    import bb.runqueue
    if isinstance(e, bb.event.BuildStarted):
        if bb.utils.to_boolean(d.getVar("DISABLE_SUDO_FORCED")):
            bb.warn("Force disabling sudo. Reason: " + d.getVar("DISABLE_SUDO_FORCED_REASON") + ".")
        display_ec_status(d)
}

################################################################################
### Helper functions.
################################################################################

# Return whether sudo is disabled in the current configuration
sudo_disabled() {
    if [ "${DISABLE_SUDO_FORCED}" = "1" ] || [ "${DISABLE_SUDO}" = "1" ]; then
        return 0 # Null return code indicates success
    else
        return 1
    fi
}

# Sudo wrapper to catch all calls to sudo from shell functions and inhibit them
# when DISABLE_SUDO or DISABLE_SUDO_FORCED are set
sudo() {
    if sudo_disabled; then
        bbplain "sudo disabled, skipping command \"sudo $@\""
    else
        # Use env to desambiguate between the wrapper and the real command
        env sudo "$@"
    fi
}
