inherit logging
inherit utility-tasks

BB_DEFAULT_TASK ?= "build_recipe"

python base_do_configure() {
    bb.plain(f"Configuring {d.getVar('PN')}")
}
addtask do_configure

python base_do_build_recipe() {
}
addtask do_build_recipe after do_configure

EXPORT_FUNCTIONS do_configure do_build_recipe