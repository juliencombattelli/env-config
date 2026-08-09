function ec_do_install {
    ec_download_latest_github_release "pkgforge-dev/ghostty-appimage" ".*${EC_CPU_ARCH}.*\.AppImage$"

    mkdir -p ~/.local/share/applications
    ln -sf ~/.config/ghostty/Ghostty.desktop ~/.local/share/applications/Ghostty.desktop

    cp "$D/latest" ~/.local/bin/ghostty.appimage
    chmod +x ~/.local/bin/ghostty.appimage
    ln -sf ~/.config/ghostty/ghostty ~/.local/bin/
}
