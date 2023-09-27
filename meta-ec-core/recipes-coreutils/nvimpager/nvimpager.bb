DESCRIPTION = ""
PN = "nvimpager"
PV = "1"

RDEPENDS += "neovim scdoc"

SRC_URI = "git://github.com/lucc/nvimpager;protocol=http;nobranch=1"
SRCREV = "v0.12.0"
SRC_URI[sha256sum] = "96569a1514438e12638844667e191d0ec94860163a3ba4342b5dfc2771bb2e96"

S = "${WORKDIR}/git"

do_install() {
    make PREFIX=$HOME/.local install
}
