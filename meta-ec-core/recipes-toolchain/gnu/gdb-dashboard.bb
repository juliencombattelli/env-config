DESCRIPTION = ""
PN = "gdb-dashboard"
PV = "1"

DEPENDS += "gdb"

SRC_URI += "git://github.com/cyrus-and/gdb-dashboard.git;protocol=http;branch=master"
SRCREV = "AUTOINC"

do_install() {
    bbplain "Installing gdb-dashboard."
    cp ${WORKDIR}/git/.gdbinit $HOME
}
