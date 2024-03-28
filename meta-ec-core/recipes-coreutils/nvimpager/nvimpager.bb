DESCRIPTION = ""
PN = "nvimpager"
NVIMPAGER_VER = "0.12.0"
PV = "${NVIMPAGER_VER}-git${SRCPV}"

DEPENDS += "scdoc make"
RDEPENDS += "neovim"

SRC_URI += "git://github.com/lucc/nvimpager;protocol=https;nobranch=1"
SRCREV = "v${NVIMPAGER_VER}"

S = "${WORKDIR}/git"

do_install() {
    if ! which make; then
        bberror "Make no installed, unable to install nvimpager."
        return
    fi
    if which scdoc 2>/dev/null; then
        INSTALL_TARGET="install"
    else
        INSTALL_TARGET="install-no-man"
    fi
    bbplain "Installing nvimpager."
    if ! make PREFIX=$HOME/.local $INSTALL_TARGET; then
        bberror "Unable to install nvimpager."
    fi
}
