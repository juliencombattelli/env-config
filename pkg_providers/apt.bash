function ec_apt_setup {
    sudo -E apt update
}

function ec_apt_pkg_search {
    local -r pattern="$1"
    apt-cache search --full --names-only "$pattern" \
        | grep --extended-regexp "^Package: " \
        | cut --delimiter=' ' --fields=2 \
        | sort --reverse --human-numeric-sort \
        | head --lines=1
}

function ec_apt_pkg_install {
    local -r pkg="$1"
    sudo -E apt install --yes "$pkg"
}
