DESCRIPTION = ""
PN = "zsh"
PV = "1"

# In case build from source is required
DEPENDS = "make gcc"

DEPENDS += "shell-common dircolors"

inherit installable

SRC_URI = "file://.zshrc"

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

do_compile() {
    ZSH_VERSION="5.9"
    bbplain "Fetching and building ZSH ${ZSH_VERSION} from sources."
    cd ${WORKDIR}
    wget https://sourceforge.net/projects/zsh/files/zsh/${ZSH_VERSION}/zsh-${ZSH_VERSION}.tar.xz
    tar -xf zsh-${ZSH_VERSION}.tar.xz
    cd zsh-${ZSH_VERSION}
    # Apt can be safely used here as we know we are on Ubuntu in WSL
    sudo -E apt-get install -y build-essential libncurses5-dev
    ./configure --with-tcsetpgrp
    make -j$(nproc)
    sudo make install
    echo "$(which zsh)" | sudo tee -a /etc/shells
}

do_configure() {
    bbplain "Configuring zsh."

    if [ -f $HOME/.zshrc ] || [ -f $HOME/.zshrc.pre-oh-my-zsh ]; then
        bbplain "Removing previous zshrc files if any"
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        mkdir -p "${EC_TARGET_INSTALL_DIR}"/backup/zsh-$TIMESTAMP/
        if [ -f $HOME/.zshrc ]; then
            mv $HOME/.zshrc "${EC_TARGET_INSTALL_DIR}"/backup/zsh-$TIMESTAMP/
        fi
        if [ -f $HOME/.zshrc.pre-oh-my-zsh ]; then
            mv $HOME/.zshrc.pre-oh-my-zsh "${EC_TARGET_INSTALL_DIR}"/backup/zsh-$TIMESTAMP/
        fi
    fi

    bbplain "Setting zsh as default shell."
    # Disable PAM's password authentication for chsh
    sudo cp /etc/pam.d/chsh /etc/pam.d/chsh.bak
    sudo sed -i 's/\(auth\s\+\)required\(\s\+pam_shells.so\)/\1sufficient\2/' /etc/pam.d/chsh
    # Change shell
    chsh -s $(which zsh)
    # Restore PAM's password authentication for chsh
    sudo mv /etc/pam.d/chsh.bak /etc/pam.d/chsh

    bbplain "Updating zshrc."
    sed "s|@EC_TARGET_INSTALL_DIR@|${EC_TARGET_INSTALL_DIR}|g" "${WORKDIR}"/.zshrc > ~/.zshrc
}
