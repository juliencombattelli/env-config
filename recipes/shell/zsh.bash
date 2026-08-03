EC_INSTALL_FROM_DISTRO_PKG_PROVIDER=1

function ec_do_install {
    ec_relink "$HOME/.zshenv" "$EC_ROOT_DIR/files/zsh/.zshenv"
}
