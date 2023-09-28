DESCRIPTION = ""
PN = "neovim"
PV = "0.9.2"

# Tag in neovim repository
NEOVIM_REV = "v${PV}"

# Use appimage if supported
DEPENDS = "libfuse2"
SRC_URI += "https://github.com/neovim/neovim/releases/download/${NEOVIM_REV}/nvim.appimage;name=appimage"
SRC_URI[appimage.sha256sum] = "61950131e18157ab9c7f14131a3dda0aa81f8e4fb47994bf6d8b418d9be6e3c0"

# Fallback to building from source if required
DEPENDS += "make gcc"
SRC_URI += "git://github.com/neovim/neovim;protocol=http;nobranch=1;name=github"
SRCREV_github = "${NEOVIM_REV}"
S = "${WORKDIR}/git"

do_install() {
    # Test the appimage
    chmod u+x "${WORKDIR}/nvim.appimage"
    if ! "${WORKDIR}/nvim.appimage" --version; then
        bbwarn "Falling back to building from sources. You may need to install Neovim dependencies manually."
        # Build from source if appimage is not working
        do_compile
    else
        # Install the appimage for the current user if working
        install -m 755 "${WORKDIR}/nvim.appimage" "$HOME/.local/bin/nvim"
    fi
}

do_compile() {
    make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=$HOME/.local
    make install
}

do_configure() {
    if [ ! -d $HOME/.config/nvim ]; then
        bbplain Downloading and installing Neovim configuration
        git clone https://github.com/juliencombattelli/neovim-config $HOME/.config/nvim
        git -C $HOME/.config/nvim remote set-url origin git@github.com:juliencombattelli/neovim-config
    else
        bbplain Neovim configuration already installed, nothing to do
    fi
}
