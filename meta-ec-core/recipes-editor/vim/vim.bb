DESCRIPTION = ""
PN = "vim"
PV = "1"

EC_DEPRECATED = "Vim recipe is not maintained ad I don't use it anymore. Use Neovim instead."

DEPENDS += "git"

inherit installable

SRC_URI += "file://vimrc"

do_configure() {
    if [ -d $HOME/.vim/bundle/Vundle.vim ]; then
        bbplain "Vundle already installed. Updating."
        git -C $HOME/.vim/bundle/Vundle.vim checkout master && git -C $HOME/.vim/bundle/Vundle.vim pull
    else
        bbplain "Installing Vundle."
        git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
    fi
    cp -r "${WORKDIR}"/vimrc $HOME/.vimrc
    vim +PluginInstall +qall
    # Uncomment listchars
    # listchars are commented by default as they seem to break vim for plugin installation
    sed -i 's/^" set listchars/set listchars/g' $HOME/.vimrc
}
