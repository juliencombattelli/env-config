DESCRIPTION = ""
PN = "neovim"
PV = "1"

DEPENDS = "make gcc"

SRC_URI = "git://github.com/neovim/neovim;protocol=http;nobranch=1"
SRCREV = "v0.9.2"

S = "${WORKDIR}/git"

do_install() {
    bbwarn "You may need to install Neovim dependencies manually"
    make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$HOME/.local
    make install
}

do_configure() {
    if [ ! -d $HOME/.config/nvim ]; then
        git clone https://github.com/juliencombattelli/neovim-config $HOME/.config/nvim
        git -C $HOME/.config/nvim remote set-url origin git@github.com:juliencombattelli/neovim-config
    fi
}
