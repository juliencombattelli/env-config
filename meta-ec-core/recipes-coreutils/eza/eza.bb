DESCRIPTION = ""
PN = "eza"
PV = "1"

SRC_URI += " https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
# Ignore the checksum check as we always fetch the latest version
BB_STRICT_CHECKSUM = "ignore"

do_install() {
    install -m 755 "${WORKDIR}/eza" "${HOME}/.local/bin"
}
