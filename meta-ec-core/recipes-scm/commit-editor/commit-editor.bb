DESCRIPTION = ""
PN = "commit-editor"
PV = "1"

DEPENDS += "git"
RDEPENDS += "neovim vscode"

SRC_URI += "file://commit-editor"

do_configure() {
    bbplain "Configuring commit editor script."
    install -m 0755 "${WORKDIR}"/commit-editor "${EC_BIN_DIR}"
    git config --global core.editor "${EC_BIN_DIR}/commit-editor"
}
