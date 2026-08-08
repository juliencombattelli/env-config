function ec_homebrew_post_prereq_setup {
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
}

function ec_homebrew_pkg_search {
    local -r pattern="$1"
    false
}

function ec_homebrew_pkg_installed {
    local -r pattern="$1"
    false
}

function ec_homebrew_pkg_install {
    local -r pkg="$1"
    false
}
