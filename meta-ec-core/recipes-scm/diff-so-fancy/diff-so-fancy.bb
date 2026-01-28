DESCRIPTION = ""
PN = "diff-so-fancy"
PV = "1"

DEPENDS += "git"

SRC_URI += "file://dsf-path.sh"

DSF_DIR = "${EC_DATA_DIR}/diff-so-fancy"

do_install() {
    if [ -d "${DSF_DIR}" ]; then
        bbplain "diff-so-fancy already installed. Updating."
        git -C "${DSF_DIR}" pull
    else
        bbplain "Installing diff-so-fancy."
        git clone https://github.com/so-fancy/diff-so-fancy "${DSF_DIR}"
    fi
}

def dsf_pager(d):
    pager = None
    if d.getVarFlag("PAGER", "git") == "diff-so-fancy":
        # Use less as default dsf pager
        pager = d.getVarFlag("PAGER", "git/diff-so-fancy") or "less"
    return pager

RDEPENDS += "${@dsf_pager(d) or ''}"

update_path() {
    cp "${WORKDIR}"/dsf-path.sh "${EC_INSTALL_DIR}"
}

update_gitconfig_interactive_diffFilter() {
    git config --global interactive.diffFilter "diff-so-fancy --patch"
}

update_gitconfig_core_pager_dsf_less() {
    git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
}

update_gitconfig_core_pager_dsf_nvimpager() {
    git config --global core.pager "diff-so-fancy --patch | nvimpager"
}

python do_configure() {
    bb.plain("Configuring diff-so-fancy.")
    bb.build.exec_func("update_path", d)
    bb.build.exec_func("update_gitconfig_interactive_diffFilter", d)
    pager = dsf_pager(d)
    if pager is not None:
        bb.build.exec_func("update_gitconfig_core_pager_dsf_" + pager, d)
}
