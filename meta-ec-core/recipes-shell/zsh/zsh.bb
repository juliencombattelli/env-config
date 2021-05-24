DESCRIPTION = ""
PN = "zsh"
PV = "1"

inherit installable

FILESPATH_prepend := "${THISDIR}/files:"

SRC_URI = "file://.zshrc"
SRC_URI[sha256sum] = "b6af836b2662f21081091e0bd851d92b2507abb94ece340b663db7e4019f8c7c"

do_build() {
    bbplain "Zsh do_build"
}

python do_install() {
    bb.build.exec_func("installable_do_install", d)
    if not d.getVar("PACKAGE_INSTALLED"):
        bb.build.exec_func("do_build", d)
}

do_configure() {
    bbplain "Configuring zsh"

    bbplain "Setting zsh as default shell"
    # Disable PAM's password authentication for chsh
    sudo cp /etc/pam.d/chsh /etc/pam.d/chsh.bak
    sudo sed -i 's/\(auth\s\+\)required\(\s\+pam_shells.so\)/\1sufficient\2/' /etc/pam.d/chsh
    # Change shell
    chsh -s /usr/bin/zsh
    # Restore PAM's password authentication for chsh
    sudo mv /etc/pam.d/chsh.bak /etc/pam.d/chsh

    bbplain "Updating .zshrc"
    sed "s|@EC_TARGET_INSTALL_DIR@|${EC_TARGET_INSTALL_DIR}|g" ${WORKDIR}/.zshrc > ~/.zshrc
}
do_configure[depends] = "oh-my-zsh:do_configure"
