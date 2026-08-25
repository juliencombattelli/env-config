EC_DEPENDS+=(zsh git)

function install_or_update {
    local -r PLUGIN_KIND="$1" # plugin or theme
    local -r PLUGIN_REPO="$2"
    local -r PLUGIN_NAME="$(basename $PLUGIN_REPO .git)"
    local -r PLUGIN_PATH="$HOME/.config/oh-my-zsh/${PLUGIN_KIND}s/$PLUGIN_NAME"
    if [ -d "$PLUGIN_PATH" ]; then
        ec_log N "oh-my-zsh plugin already installed: $PLUGIN_NAME. Updating."
        git -C "$PLUGIN_PATH" pull
    else
        ec_log N "Installing oh-my-zsh plugin: $PLUGIN_NAME."
        git clone "$PLUGIN_REPO" "$PLUGIN_PATH"
    fi
}

function ec_do_install {
    # Must be synchro with .zshrc
    export ZSH="$HOME/.local/state/oh-my-zsh"
    # Must be synchro with .zshenv
    export ZDOTDIR="$HOME/.config/zsh"

    if [ ! -e "$ZSH" ]; then
        ec_log N "Installing oh-my-zsh."
        wget --directory-prefix="$D" --no-verbose --timestamping https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
        KEEP_ZSHRC=yes sh "$D/install.sh" --unattended
    else
        ec_log N "oh-my-zsh is already installed."
    fi

    ec_log N "Installing oh-my-zsh plugins."
    install_or_update theme https://github.com/romkatv/powerlevel10k.git
    install_or_update plugin https://github.com/zsh-users/zsh-syntax-highlighting.git
    install_or_update plugin https://github.com/zsh-users/zsh-completions.git
    install_or_update plugin https://github.com/jirutka/zsh-shift-select.git
}
