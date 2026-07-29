function ec_do_install {
    ec_download_latest_github_release "eza-community/eza" "${EC_CPU_ARCH}.*linux-musl.*\.tar\..*"

    tar -xf "$D/latest"

    cp eza ~/.local/bin/
}
