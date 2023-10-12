DESCRIPTION = ""
PN = "diff-so-fancy"
PV = "1"

do_install() {
    if [ -d ${EC_TARGET_INSTALL_DIR}/share/diff-so-fancy ]; then
        bbplain "diff-so-fancy already installed. Updating."
        git -C ${EC_TARGET_INSTALL_DIR}/share/diff-so-fancy pull
    else
        bbplain "Installing diff-so-fancy."
        git clone https://github.com/so-fancy/diff-so-fancy ${EC_TARGET_INSTALL_DIR}/share/diff-so-fancy
    fi
}
do_install[depends] = "git:do_complete"
