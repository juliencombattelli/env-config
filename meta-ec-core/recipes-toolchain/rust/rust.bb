DESCRIPTION = ""
PN = "rust"
PV = "1"

SRC_URI += " \
    file://rust.sh \
    https://sh.rustup.rs;downloadfilename=rustup-init.sh \
"
# Ignore the checksum check as we always fetch the latest version
BB_STRICT_CHECKSUM = "ignore"

do_install() {
    . "${WORKDIR}/rust.sh"

    cp "${WORKDIR}/rust.sh" "${EC_INSTALL_DIR}"

    if [ -d "$RUSTUP_HOME" ]; then
        bbplain "rustup already installed."
        return
    else
        bbplain "Installing rustup."
        bash "${WORKDIR}/rustup-init.sh" --no-modify-path -y
    fi
}
