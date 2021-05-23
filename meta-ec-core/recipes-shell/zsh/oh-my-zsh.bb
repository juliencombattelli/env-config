DESCRIPTION = ""
PN = "oh-my-zsh"
PV = "1"

inherit installable

do_install() {
    wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    bash ./install.sh --unattended
}
do_install[depends] = "zsh:do_install"

do_configure() {
    bbplain "Installing oh-my-zsh plugins"
    # Install plugins
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}
