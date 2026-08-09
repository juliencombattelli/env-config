function ec_do_install {
    ec_download_latest_github_release "pkgforge-dev/ghostty-appimage" ".*${EC_CPU_ARCH}.*\.AppImage$"

    mkdir -p ~/.local/share/applications
    ec_relink ~/.local/share/applications/Ghostty.desktop ~/.config/ghostty/Ghostty.desktop

    cp "$D/latest" ~/.local/bin/ghostty.appimage
    chmod +x ~/.local/bin/ghostty.appimage
    ec_relink ~/.local/bin/ ~/.config/ghostty/ghostty
}
