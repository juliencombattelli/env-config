DESCRIPTION = ""
PN = "gdb-dashboard"
PV = "1.0-git${SRCPV}"

DEPENDS += "gdb"

SRC_URI += "git://github.com/cyrus-and/gdb-dashboard.git;protocol=https;branch=master"
SRCREV = "AUTOINC"

do_install() {
    bbplain "Installing gdb-dashboard."
    mkdir -p $HOME/.config/gdb
    cp ${WORKDIR}/git/.gdbinit $HOME/config/gdb/gdbinit
}
