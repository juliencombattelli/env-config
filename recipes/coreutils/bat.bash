function ec_do_install {
    ec_download_latest_github_release "sharkdp/bat" "${EC_CPU_ARCH}.*linux-musl.*\.tar\..*"

    # TODO untar and install
}
