function ec_dnf_setup {
    if $EC_FEDORA_ATOMIC; then
        true
    else
        true
    fi
}

function ec_dnf_pkg_search {
    local -r pattern="$1"
    if $EC_FEDORA_ATOMIC; then
        false
    else
        false
    fi
}

function ec_dnf_pkg_installed {
    local -r pattern="$1"
    if $EC_FEDORA_ATOMIC; then
        false
    else
        false
    fi
}

function ec_dnf_pkg_install {
    local -r pkg="$1"
    if $EC_FEDORA_ATOMIC; then
        false
    else
        false
    fi
}
