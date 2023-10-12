DESCRIPTION = ""
PN = "vim"
PV = "1"

inherit installable

FILESPATH:prepend := "${THISDIR}/files:"

SRC_URI = "file://vimrc"

do_configure() {
    if [ -d ~/.vim/bundle/Vundle.vim ]; then
        bbplain "Vundle already installed. Updating."
        git -C ~/.vim/bundle/Vundle.vim checkout master && git -C ~/.vim/bundle/Vundle.vim pull
    else
        bbplain "Installing Vundle."
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    fi
    cp -r "${WORKDIR}"/vimrc $HOME/.vimrc
    vim +PluginInstall +qall
    # Uncomment listchars
    # listchars are commented by default as they seem to break vim for plugin installation
    sed -i 's/^" set listchars/set listchars/g' $HOME/.vimrc
}
do_configure[depends] = "git:do_complete"
