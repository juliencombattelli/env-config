function ec_dnf_setup {
    if $EC_FEDORA_ATOMIC; then
        true
    else
        sudo -E dnf update --assumeyes
    fi
}

function ec_dnf_pkg_search {
    local -r pattern="$1"
    if $EC_FEDORA_ATOMIC; then
        false
    else
        dnf --quiet repoquery --queryformat '%{name}\n' '*' \
            | grep -E "$pattern" \
            | sort --reverse --human-numeric-sort \
            | head --lines=1
    fi
}

function ec_dnf_pkg_installed {
    local -r pattern="$1"
    if $EC_FEDORA_ATOMIC; then
        false
    else
        rpm --query --all --queryformat='%{NAME}\n' \
            | grep -E "$pattern"
    fi
}

function ec_dnf_pkg_install {
    local -r pkg="$1"
    if $EC_FEDORA_ATOMIC; then
        false
    else
        sudo -E dnf install --assumeyes "$pkg"
    fi
}
