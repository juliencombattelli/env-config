DESCRIPTION = ""
PN = "vim"
PV = "1"

inherit installable

FILESPATH_prepend := "${THISDIR}/files:"

SRC_URI = "file://vimrc"

do_configure() {
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    cp -r "${WORKDIR}"/vimrc $HOME/.vimrc
    vim +PluginInstall +qall &>/dev/null
}
