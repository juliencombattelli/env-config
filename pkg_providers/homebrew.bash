function ec_homebrew_pkg_search {
    local -r pattern="$1"
    brew formulae \
        | grep -E "$pattern" \
        | sort --reverse --human-numeric-sort \
        | head --lines=1
}

function ec_homebrew_pkg_installed {
    local -r pattern="$1"
    brew list --formulae -1 \
        | grep -E "$pattern"
}

function ec_homebrew_pkg_install {
    local -r pkg="$1"
    brew install --yes "$pkg"
}
