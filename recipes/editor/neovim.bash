function ec_do_install {
    ec_download_latest_github_release "neovim/neovim" "linux.*${EC_CPU_ARCH}.*\.appimage$"

    cp "$D/latest" ~/.local/bin/nvim
    chmod +x ~/.local/bin/nvim
    ln -sf ~/.local/bin/nvim ~/.local/bin/vim

    if [ ! -d ~/.config/nvim ]; then
        ec_log N "Downloading and installing Neovim configuration."
        git clone https://github.com/juliencombattelli/neovim-config ~/.config/nvim -b v2
    else
        ec_log N "Neovim configuration already installed, nothing to do."
    fi
}
