function ec_do_install {
    local running_ghostty=false
    if [ "${TERM_PROGRAM:-}" = "ghostty" ]; then
        running_ghostty=true
        local ghostty_version="$(ghostty --version | head --lines=1 | cut -d' ' -f2)"
    fi

    ec_download_latest_github_release "pkgforge-dev/ghostty-appimage" ".*${EC_CPU_ARCH}.*\.AppImage$"

    mkdir -p ~/.local/share/applications
    ec_relink ~/.local/share/applications/com.mitchellh.ghostty.desktop ~/.config/env-config/files/ghostty/com.mitchellh.ghostty.desktop

    if [ -e ~/.local/bin/ghostty.appimage ]; then
        mv ~/.local/bin/ghostty.appimage ~/.local/bin/ghostty.appimage.old
    fi
    cp "$D/latest" ~/.local/bin/ghostty.appimage
    if [ -e ~/.local/bin/ghostty.appimage.old ]; then
        rm ~/.local/bin/ghostty.appimage.old
    fi
    chmod +x ~/.local/bin/ghostty.appimage
    ec_relink ~/.local/bin/ghostty ~/.local/bin/ghostty.appimage

    if $running_ghostty; then
        local new_ghostty_version="$(ghostty --version | head --lines=1 | cut -d' ' -f2)"
        if [ "$ghostty_version" != "$new_ghostty_version" ]; then
            ec_log W "Quit all Ghostty windows and relaunch it to use the update."
        fi
    fi
}
