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
    # Disable PAM's password authentication for chsh
    sudo cp /etc/pam.d/chsh /etc/pam.d/chsh.bak
    sudo sed -i 's/\(auth\s\+\)required\(\s\+pam_shells.so\)/\1sufficient\2/' /etc/pam.d/chsh
    # Change shell
    chsh -s zsh
    # Restore PAM's password authentication for chsh
    sudo mv /etc/pam.d/chsh.bak /etc/pam.d/chsh
}
do_configure[depends] = "oh-my-zsh:do_configure"