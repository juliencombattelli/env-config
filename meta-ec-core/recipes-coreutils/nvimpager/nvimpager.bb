DESCRIPTION = ""
PN = "nvimpager"
PV = "1"

DEPENDS += "scdoc make"
RDEPENDS += "neovim"

SRC_URI = "git://github.com/lucc/nvimpager;protocol=http;nobranch=1"
SRCREV = "v0.12.0"
SRC_URI[sha256sum] = "96569a1514438e12638844667e191d0ec94860163a3ba4342b5dfc2771bb2e96"

S = "${WORKDIR}/git"

do_install() {
    if which scdoc 2>/dev/null; then
        INSTALL_TARGET="install"
    else
        INSTALL_TARGET="install-no-man"
    fi
    make PREFIX=$HOME/.local $INSTALL_TARGET
}
