function ec_apt_setup {
    if [[ -z ${EC_DISABLE_PKG_PROVIDERS_UPDATE} ]]; then
        sudo -E apt update
    fi
}

function ec_apt_pkg_search {
    local -r pattern="$1"
    apt-cache pkgnames \
        | grep -E "$pattern" \
        | sort --reverse --human-numeric-sort \
        | head --lines=1
}

function ec_apt_pkg_install {
    local -r pkg="$1"
    sudo -E apt install --yes "$pkg"
}
