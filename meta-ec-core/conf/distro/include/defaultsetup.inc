# Space-separated list of package managers to use by descending priority.
# If no package manager allows the installation of a given software, it is built from source if a
# SRC_URI is provided.
# Use =/+=/=+ to overwrite the list, :append/:prepend to modify it.
# Default: pip, a package manager available almost everywhere.
# TODO remove as it is now excluded by default
DISTRO_PKG_PROVIDERS ?= "pip"

# Space-separated list of packages to install on the given distribution.
# Use =/+=/=+ to overwrite the list, :append/:prepend to modify it.
# Default: all the packages I regularly use on all environments.
PKG_INSTALL ?= " \
    neovim vim vscode \
    ssh \
    commit-editor diff-so-fancy git repo-aliases \
    aliases bash requests-ca-bundle oh-my-zsh proxy \
    bat exa fd nvimpager ripgrep \
    cmake gcc gdb gdb-dashboard make ninja clang-format clang-tidy clang \
"
