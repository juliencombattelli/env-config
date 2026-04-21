DESCRIPTION = ""
PN = "fzf"
PV = "1"

SRC_URI += " https://github.com/junegunn/fzf/releases/download/v0.71.0/fzf-0.71.0-linux_amd64.tar.gz;name=fzf.tar.gz"
SRC_URI[fzf.tar.gz.sha256sum] = "22639bb38489dbca8acef57850cbb50231ab714d0e8e855ac52fae8b41233df4"

SRC_URI += " file://fzf.zsh "

do_install() {
    install -m 755 "${WORKDIR}/fzf" "${EC_BIN_DIR}"
}

do_configure() {
    install -m 644 "${WORKDIR}/fzf.zsh" "${EC_INSTALL_DIR}"
}
