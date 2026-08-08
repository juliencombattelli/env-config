EC_DEPENDS+=(git perl)

function ec_do_install {
    local -r DSF_DIR="$HOME/.local/share/diff-so-fancy"
    if [ -d "${DSF_DIR}" ]; then
        ec_log N "diff-so-fancy already installed. Updating."
        git -C "${DSF_DIR}" pull
    else
        ec_log N "Installing diff-so-fancy."
        git clone https://github.com/so-fancy/diff-so-fancy "${DSF_DIR}"
    fi
}
