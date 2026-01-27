# Space-separated list of packages to install on the given distribution.
# Use =/+=/=+ to overwrite the list, :append/:prepend to modify it.
# Default: all the packages I regularly use on all environments.
PKG_INSTALL ?= " \
    neovim vscode \
    ssh \
    commit-editor diff-so-fancy git repo-aliases \
    aliases bash requests-ca-bundle oh-my-zsh proxy \
    bat eza fd nvimpager ripgrep \
    cmake gcc gdb gdb-dashboard make ninja clang-format clang-tidy clang \
"
