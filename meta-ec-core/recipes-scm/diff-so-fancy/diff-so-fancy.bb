DESCRIPTION = ""
PN = "diff-so-fancy"
PV = "1"

DEPENDS = "git"

do_install() {
    if [ -d ${EC_TARGET_INSTALL_DIR}/share/diff-so-fancy ]; then
        bbplain "diff-so-fancy already installed. Updating."
        git -C ${EC_TARGET_INSTALL_DIR}/share/diff-so-fancy pull
    else
        bbplain "Installing diff-so-fancy."
        git clone https://github.com/so-fancy/diff-so-fancy ${EC_TARGET_INSTALL_DIR}/share/diff-so-fancy
    fi
}

def with_nvimpager(d):
    return "nvimpager" in d.getVar("PKG_INSTALL")

RDEPENDS = "${@'nvimpager' if with_nvimpager(d) else ''}"

update_gitconfig_interactive_diffFilter() {
    git config --global interactive.diffFilter "diff-so-fancy --patch"
}

update_gitconfig_core_pager() {
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
}

update_gitconfig_core_pager_with_nvimpager() {
    git config --global core.pager "diff-so-fancy --patch | nvimpager"
}

python do_configure() {
    bb.plain("Configuring diff-so-fancy.")
    bb.build.exec_func("update_gitconfig_interactive_diffFilter", d)
    if with_nvimpager(d):
        bb.build.exec_func("update_gitconfig_core_pager_with_nvimpager", d)
    else
        bb.build.exec_func("update_gitconfig_core_pager", d)
}
