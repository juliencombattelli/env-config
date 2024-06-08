DESCRIPTION = ""
PN = "neovim"
NEOVIM_VER = "0.10.0"
PV = "${NEOVIM_VER}-git${SRCPV}"

# Tag in neovim repository
NEOVIM_TAG = "v${NEOVIM_VER}"

# Use appimage if supported
DEPENDS += "libfuse2"
SRC_URI += "https://github.com/neovim/neovim/releases/download/${NEOVIM_TAG}/nvim.appimage;name=appimage"
SRC_URI[appimage.sha256sum] = "6a021e9465fe3d3375e28c3e94c1c2c4f7d1a5a67e4a78cf52d18d77b1471390"

# Fallback to building from source if required
# Always download neovim for now even if not building from source as I regularly refer to the source code
DEPENDS += "cmake make gcc"
SRC_URI += "git://github.com/neovim/neovim;protocol=https;nobranch=1;name=github"
SRCREV_github = "${NEOVIM_TAG}"
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
        sudo install -m 755 "${WORKDIR}/nvim.appimage" "/usr/local/bin/nvim"
    fi
}

do_compile() {
    if sudo_disabled; then
        NEOVIM_INSTALL_PREFIX="CMAKE_INSTALL_PREFIX=$HOME/.local"
        NEOVIM_SUDO=""
    else
        NEOVIM_INSTALL_PREFIX=""
        NEOVIM_SUDO="sudo"
    fi

    if ! make CMAKE_BUILD_TYPE=Release $NEOVIM_INSTALL_PREFIX; then
        bberror "Unable to build neovim from source."
        return
    fi

    if sudo_disabled; then
        bbplain "Sudo disabled, installing neovim for the local user."
    else
        bbplain "Sudo enabled, installing neovim globally."
    fi

    if ! $NEOVIM_SUDO make install; then
        bberror "Unable to install neovim."
        return
    fi
}

do_configure() {
    if [ ! -d $HOME/.config/nvim ]; then
        bbplain "Downloading and installing Neovim configuration."
        git clone https://github.com/juliencombattelli/neovim-config $HOME/.config/nvim
        git -C $HOME/.config/nvim remote set-url origin git@github.com:juliencombattelli/neovim-config
    else
        bbplain "Neovim configuration already installed, nothing to do."
    fi
}
