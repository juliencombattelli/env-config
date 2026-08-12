function ec_do_install {
    ec_download_latest_github_release "pkgforge-dev/ghostty-appimage" ".*${EC_CPU_ARCH}.*\.AppImage$"

    mkdir -p ~/.local/share/applications
    ec_relink ~/.local/share/applications/com.mitchellh.ghostty.desktop ~/.config/env-config/files/ghostty/com.mitchellh.ghostty.desktop

    cp "$D/latest" ~/.local/bin/ghostty.appimage
    chmod +x ~/.local/bin/ghostty.appimage
    ec_relink ~/.local/bin/ghostty ~/.local/bin/ghostty.appimage
}
