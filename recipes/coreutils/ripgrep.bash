function ec_do_install {
    ec_download_latest_github_release "BurntSushi/ripgrep" "${EC_CPU_ARCH}.*linux-musl.*\.tar\.gz$"

    tar -xf "$D/latest"

    cd "$(dirname "$(find . -name rg)")" || return 1

    cp rg ~/.local/bin/
}
