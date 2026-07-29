function ec_do_install {
    ec_download_latest_github_release "sharkdp/bat" "${EC_CPU_ARCH}.*linux-musl.*\.tar\..*"

    tar -xf "$D/latest"

    cd "$(dirname "$(find . -name bat)")" || return 1

    cp bat ~/.local/bin/
}
