DESCRIPTION = ""
PN = "oh-my-zsh"
PV = "1"

inherit installable

SRC_URI = "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/1e277553bcc9f23a904bf728013df6ebfe339e74/tools/install.sh"
SRC_URI[sha256sum] = "6ad30a2c638fea177a2f6701cbbf5e5e7dc7f44711e89708c89f4735be8320cd"

do_install() {
    if [ -d ${ZSH:-$HOME/.oh-my-zsh} ]; then
        bbplain "oh-my-zsh already installed. Updating."
        git -C ${ZSH:-$HOME/.oh-my-zsh} pull
    else
        bbplain "Installing oh-my-zsh."
        bash ${WORKDIR}/install.sh --unattended

        bbplain "Installing oh-my-zsh plugins."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-completions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions
    fi
}
do_install[depends] += "zsh:do_install git:do_build_recipe"
