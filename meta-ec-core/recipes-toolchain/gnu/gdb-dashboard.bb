DESCRIPTION = ""
PN = "gdb-dashboard"
PV = "1.0-git${SRCPV}"

DEPENDS += "gdb"

SRC_URI += "git://github.com/cyrus-and/gdb-dashboard.git;protocol=https;branch=master"
SRCREV = "AUTOINC"

do_install() {
    bbplain "Installing gdb-dashboard."
    mkdir -p ${EC_CONFIG_DIR}/gdb
    cp ${WORKDIR}/git/.gdbinit ${EC_CONFIG_DIR}/gdb/gdbinit
}
