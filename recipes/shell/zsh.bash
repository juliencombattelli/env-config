EC_DEPENDS+=(make gcc)
EC_DEPENDS+=(shell-common)

FILES_URI+=(file://fragment.zshenv file://.zshrc)

function ec_do_install {
    echo "Installing zsh!"
}
