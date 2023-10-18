DESCRIPTION = ""
PN = "commit-editor"
PV = "1"

DEPENDS += "git"
RDEPENDS += "neovim vim vscode"

SRC_URI += "file://commit-editor"

do_configure() {
    bbplain "Configuring commit editor script."
    install -m 0755 "${WORKDIR}"/commit-editor "${EC_TARGET_INSTALL_DIR}"/bin/
    git config --global core.editor "${EC_TARGET_INSTALL_DIR}/bin/commit-editor"
}
