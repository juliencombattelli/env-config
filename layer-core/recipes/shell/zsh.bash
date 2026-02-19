DEPENDS+=(make gcc)
DEPENDS+=(shell-common)

FILES_URI+=(file://fragment.zshenv file://.zshrc)

function do_install {
    echo "Installing zsh!"
}
