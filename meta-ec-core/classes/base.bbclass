inherit logging
inherit utility-tasks

BB_DEFAULT_TASK ?= "configure"

# Install a software locally
python base_do_install() {
    bb.plain(f"Install {d.getVar('PN')}")
}
addtask do_install

# Configure and installed software
python base_do_configure() {
    bb.plain(f"Configure {d.getVar('PN')}")
}
addtask do_configure after do_install
do_configure[nostamp] = "1"

EXPORT_FUNCTIONS do_install do_configure