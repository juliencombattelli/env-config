DESCRIPTION = ""
PN = "git"
PV = "1"

inherit installable

do_configure() {
    bbplain "Configuring git."
    git config --global user.email "julien.combattelli@gmail.com"
    git config --global user.name "Julien Combattelli"
    git config --global color.ui "always"
    git config --global core.editor "${EC_TARGET_INSTALL_DIR}/bin/commit-editor"
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
    git config --global interactive.diffFilter "diff-so-fancy --patch"
}
