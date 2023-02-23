python () {
    import sys
    d.setVar('PYTHON_VERSION', '{}.{}'.format(sys.version_info.major, sys.version_info.minor))
}

BB_STRICT_CHECKSUM = "0"

# Handle multiple python version for get-pip.py using Bitbake's mirror mechanism
# (an alternative could be to always use https://bootstrap.pypa.io/pip/3.6/get-pip.py)
# First look for get-pip.py for our specific python version
SRC_URI := " https://bootstrap.pypa.io/pip/${PYTHON_VERSION}/get-pip.py "
# Then if it is not found, use the generic one (replace the lhs url with the rhs one)
MIRRORS = " https://bootstrap.pypa.io/pip/.*/ https://bootstrap.pypa.io/ "

do_install() {
    bbplain "Installing pip."
    if ! python3 -m pip --version; then
        python3 ${WORKDIR}/get-pip.py
    else
        bbplain "pip already installed."
    fi

    bbplain "Installing pypisearch."
    python3 -m pip install pypisearch
}
addtask do_install before do_update

do_update() {
    bbplain "Updating pip."
    python3 -m pip install --upgrade pip
}
addtask do_update before do_configure

# Always consider do_update as out-of-date
do_update[nostamp] = "1"

do_configure[noexec] = "1"
