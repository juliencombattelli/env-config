DESCRIPTION = ""
PN = "oh-my-zsh"
PV = "1"

DEPENDS += "zsh git"

inherit installable

SRC_URI += " \
    file://p10k.zsh \
    file://p10k.zsh.post.zsh \
    file://zsh-shift-select-ext.zsh \
    file://file://zsh-swap-last-args.zsh \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/1e277553bcc9f23a904bf728013df6ebfe339e74/tools/install.sh;name=omz \
"
SRC_URI[omz.sha256sum] = "6ad30a2c638fea177a2f6701cbbf5e5e7dc7f44711e89708c89f4735be8320cd"

install_or_update() {
    PLUGIN_KIND="$1" # plugin or theme
    PLUGIN_REPO="$2"
    PLUGIN_NAME="$(basename $PLUGIN_REPO .git)"
    PLUGIN_PATH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/${PLUGIN_KIND}s/$PLUGIN_NAME"
    if [ -d "$PLUGIN_PATH" ]; then
        bbplain "oh-my-zsh plugin already installed: $PLUGIN_NAME. Updating."
        git -C "$PLUGIN_PATH" pull
    else
        bbplain "Installing oh-my-zsh plugin: $PLUGIN_NAME."
        git clone "$PLUGIN_REPO" "$PLUGIN_PATH"
    fi
}

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
    fi

    bbplain "Installing oh-my-zsh plugins."

    install_or_update theme https://github.com/romkatv/powerlevel10k.git
    install_or_update plugin https://github.com/zsh-users/zsh-syntax-highlighting.git
    install_or_update plugin https://github.com/zsh-users/zsh-completions.git
    install_or_update plugin https://github.com/jirutka/zsh-shift-select.git
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
    cp "${WORKDIR}"/p10k.zsh.post.zsh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp "${WORKDIR}"/zsh-shift-select-ext.zsh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp "${WORKDIR}"/zsh-swap-last-args.zsh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
