function ec_apt_setup {
    if [[ -z ${EC_DISABLE_PKG_PROVIDERS_UPDATE} ]]; then
        sudo -E DEBIAN_FRONTEND=noninteractive NEEDRESTART_SUSPEND=1 \
            apt-get update
    fi
}

function ec_apt_pkg_search {
    local -r pattern="$1"
    apt-cache pkgnames \
        | grep -E "$pattern" \
        | sort --reverse --human-numeric-sort \
        | head --lines=1
}

function ec_apt_pkg_installed {
    local -r pattern="$1"
    dpkg-query --show --showformat='${Package}\t${db:Status-Abbrev}\n' \
        | grep -E $'\tii $' \
        | cut -f1 \
        | grep -E "$pattern"
}

function ec_apt_pkg_install {
    local -r pkg="$1"
    sudo -E DEBIAN_FRONTEND=noninteractive NEEDRESTART_SUSPEND=1 \
        apt-get install --yes --no-install-recommends "$pkg"
}
