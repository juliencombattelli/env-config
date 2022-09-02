DESCRIPTION = ""
PN = "gdb-dashboard"
PV = "1"

SRC_URI = "https://git.io/.gdbinit"
SRC_URI[sha256sum] = "d4f0c5a01646e19d5b255d12911ea2131ffeeb42331df410333a14aa244c0214"

do_install() {
    bbplain "Installing gdb-dashboard."
    cp ${WORKDIR}/.gdbinit ~
}
do_install[depends] += "gdb:do_install"
