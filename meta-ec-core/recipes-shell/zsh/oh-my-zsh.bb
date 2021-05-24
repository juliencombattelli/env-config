DESCRIPTION = ""
PN = "oh-my-zsh"
PV = "1"

inherit installable

SRC_URI = "https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
SRC_URI[sha256sum] = "b6af836b2662f21081091e0bd851d92b2507abb94ece340b663db7e4019f8c7c"

do_install() {
    bbplain "Installing oh-my-zsh"
    bash ${WORKDIR}/install.sh --unattended

    bbplain "Installing oh-my-zsh plugins"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}
do_install[depends] = "zsh:do_install"
