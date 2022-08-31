DESCRIPTION = ""
PN = "zsh"
PV = "1"

inherit installable

FILESPATH:prepend := "${THISDIR}/files:"

SRC_URI = "file://.zshrc"
SRC_URI[sha256sum] = "b6af836b2662f21081091e0bd851d92b2507abb94ece340b663db7e4019f8c7c"

python do_install() {
    zsh_not_installed = run_shell_cmd(d, "which zsh").returncode
    if zsh_not_installed:
        bb.build.exec_func("installable_do_install", d)
        if not d.getVar("PACKAGE_INSTALLED"):
            if d.getVar("PLATFORM").startswith("wsl") and d.getVar("DISTRO").startswith("ubuntu"):
                bb.build.exec_func("do_compile", d)
            else:
                bb.error("Building ZSH is only supported on Ubuntu in WSL.")
}
# In case build from source is required
do_install[depends] = "make:do_build_recipe gcc:do_build_recipe"

do_compile() {
    bbplain "Building ZSH from sources."
    cd ${WORKDIR}
    wget https://sourceforge.net/projects/zsh/files/zsh/5.8/zsh-5.8.tar.xz
    tar -xf zsh-5.8.tar.xz
    cd zsh-5.8
    sudo apt install build-essential libncurses5-dev
    ./configure --with-tcsetpgrp
    make -j$(nproc)
    sudo make install
    echo "$(which zsh)" | sudo tee -a /etc/shells
}

do_configure() {
    bbplain "Configuring zsh."

    bbplain "Setting zsh as default shell."
    # Disable PAM's password authentication for chsh
    sudo cp /etc/pam.d/chsh /etc/pam.d/chsh.bak
    sudo sed -i 's/\(auth\s\+\)required\(\s\+pam_shells.so\)/\1sufficient\2/' /etc/pam.d/chsh
    # Change shell
    chsh -s $(which zsh)
    # Restore PAM's password authentication for chsh
    sudo mv /etc/pam.d/chsh.bak /etc/pam.d/chsh

    bbplain "Updating zshrc."
    sed "s|@EC_TARGET_INSTALL_DIR@|${EC_TARGET_INSTALL_DIR}|g" ${WORKDIR}/.zshrc > ~/.zshrc
}
do_configure[depends] = "oh-my-zsh:do_configure"
