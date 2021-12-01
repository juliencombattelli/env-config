DESCRIPTION = ""
PN = "oh-my-zsh"
PV = "1"

inherit installable

# TODO point to stable file to not have to update sha256sum at each update
SRC_URI = "https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
SRC_URI[sha256sum] = "fa95142f9a4986e01cdd69e4b96c5e4613aff8dcbd7dab6fcca8f7517abd1690"

do_install() {
    if [ -d ${ZSH:-$HOME/.oh-my-zsh} ]; then
        bbplain "oh-my-zsh already installed. Updating."
        git -C ${ZSH:-$HOME/.oh-my-zsh} pull
    else
        bbplain "Installing oh-my-zsh"
        bash ${WORKDIR}/install.sh --unattended

        bbplain "Installing oh-my-zsh plugins."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi
}
do_install[depends] += "zsh:do_install git:do_build_recipe"
