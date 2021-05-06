DESCRIPTION = ""
PN = "zsh"
PV = "1"

python do_compile() {
    bb.plain(f"!!! Compiling {d.getVar('PN')}")
}

python do_install() {
    bb.plain(f"!!! Installing {d.getVar('PN')}")
}

python do_configure() {
    bb.plain(f"!!! Configure {d.getVar('PN')}")
}