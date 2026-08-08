function ec_dnf_setup {
    : #sudo -E dnf update --assumeyes
}

function ec_dnf_pkg_search {
    local -r pattern="$1"
    dnf --quiet repoquery --queryformat '%{name}\n' '*' \
        | grep -E "$pattern" \
        | sort --reverse --human-numeric-sort \
        | head --lines=1
}

function ec_dnf_pkg_installed {
    local -r pattern="$1"
    rpm --query --all --queryformat='%{NAME}\n' \
        | grep -E "$pattern"
}

function ec_dnf_pkg_install {
    local -r pkg="$1"
    sudo -E dnf install --assumeyes "$pkg"
}
