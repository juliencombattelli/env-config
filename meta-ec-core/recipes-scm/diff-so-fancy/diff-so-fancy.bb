DESCRIPTION = ""
PN = "diff-so-fancy"
PV = "1"

do_install() {
    git clone https://github.com/so-fancy/diff-so-fancy ${EC_TARGET_INSTALL_DIR}/share/diff-so-fancy
}
