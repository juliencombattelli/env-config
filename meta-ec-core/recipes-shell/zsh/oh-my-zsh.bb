DESCRIPTION = ""
PN = "oh-my-zsh"
PV = "1"

DEPENDS += "zsh git"

inherit installable

SRC_URI += " \
    file://p10k.zsh \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/1e277553bcc9f23a904bf728013df6ebfe339e74/tools/install.sh;name=omz \
"
SRC_URI[omz.sha256sum] = "6ad30a2c638fea177a2f6701cbbf5e5e7dc7f44711e89708c89f4735be8320cd"

do_install() {
    if ! which zsh; then
        bbwarn "Zsh not installed, skipping oh-my-zsh installation."
        return
    elif [ -d ${ZSH:-$HOME/.oh-my-zsh} ]; then
        bbplain "oh-my-zsh already installed. Updating."
        git -C ${ZSH:-$HOME/.oh-my-zsh} pull
    else
        bbplain "Installing oh-my-zsh."
        bash ${WORKDIR}/install.sh --unattended

        bbplain "Installing oh-my-zsh plugins."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions
    fi
}

do_configure() {
    if ! which zsh; then
        bbwarn "Zsh not installed, skipping oh-my-zsh configuration."
        return
    else
        bbplain "Configuring oh-my-zsh."
    fi

    # OMZ automatically backup the zshrc file before installation
    # Restore the backed up one as it is the one from env-config
    if [ -f $HOME/.zshrc.pre-oh-my-zsh ]; then
        mv $HOME/.zshrc.pre-oh-my-zsh $HOME/.zshrc
    fi

    # Install additional files
    cp "${WORKDIR}"/p10k.zsh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
