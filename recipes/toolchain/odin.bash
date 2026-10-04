function ec_do_install {
    ODIN_CPU_ARCH=$EC_CPU_ARCH
    if [[ ${ODIN_CPU_ARCH} == x86_64 ]]; then
        # Patch up arch name to follow Odin naming convention
        ODIN_CPU_ARCH=amd64
    fi

    echo "Installing odin"

    ec_download_latest_github_release "odin-lang/Odin" ".*linux-${ODIN_CPU_ARCH}.*\.tar\.gz$"

    tar -xf "$D/latest"

    ODIN_TOOLCHAINS_DIR=~/.local/share/odin-toolchains

    mkdir -p "$ODIN_TOOLCHAINS_DIR"
    if [[ "$(find "$ODIN_TOOLCHAINS_DIR" -mindepth 1 -maxdepth 1 -type d)" ]]; then
        ec_log W "$ODIN_TOOLCHAINS_DIR is not empty, previous Odin installations will not be removed"
    fi

    ODIN_CURRENT=(odin*)
    if [[ ${#ODIN_CURRENT[@]} > 1 ]]; then
        ec_log E "Multiple directories in $W, aborting."
        return 1
    fi

    # Copy toolchain only if it does not exist yet
    if [[ ! -e "$ODIN_TOOLCHAINS_DIR/${ODIN_CURRENT[0]}" ]]; then
        mv "${ODIN_CURRENT[0]}" "$ODIN_TOOLCHAINS_DIR"
    fi

    ec_relink "$ODIN_TOOLCHAINS_DIR/current" "${ODIN_CURRENT[0]}"
}
