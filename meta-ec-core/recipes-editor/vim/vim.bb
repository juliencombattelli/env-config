DESCRIPTION = ""
PN = "vim"
PV = "1"

inherit installable

FILESPATH_prepend := "${THISDIR}/files:"

SRC_URI = "file://vimrc"

do_configure() {
    if [ -d ~/.vim/bundle/Vundle.vim ]; then
        bbplain "Vundle already installed. Updating."
        git -C ~/.vim/bundle/Vundle.vim pull
    else
        bbplain "Installing Vundle."
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    fi
    cp -r "${WORKDIR}"/vimrc $HOME/.vimrc
    vim +PluginInstall +qall &>/dev/null
}
do_configure[depends] = "git:do_build_recipe"
