DESCRIPTION = ""
PN = "zsh"
PV = "1"

inherit installable

do_build() {
    bbplain "Zsh do_build"
}

python do_install() {
    bb.build.exec_func("installable_do_install", d)
    if not d.getVar("PACKAGE_INSTALLED"):
        bb.build.exec_func("do_build", d)
}

do_configure() {
    bbplain "Configuring zsh and oh-my-zsh"
    chsh -s zsh
}
do_configure[depends] = "oh-my-zsh:do_configure"