function ec_do_install {
    mkdir -p ~/.cache/
    mkdir -p ~/.config/
    mkdir -p ~/.local/bin/
    mkdir -p ~/.local/include/
    mkdir -p ~/.local/lib/
    mkdir -p ~/.local/share/
    mkdir -p ~/.local/state/

    ec_relink "$HOME/.config/env-config" "$EC_ROOT_DIR"
}