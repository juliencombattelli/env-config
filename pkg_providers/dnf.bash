function ec_dnf_setup {
    true
}

function ec_dnf_pkg_search {
    local -r pattern="$1"
    false
}

function ec_dnf_pkg_install {
    local -r pkg="$1"
    false
}
