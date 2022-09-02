# Space-separated list of package managers to use by descending priority.
# If no package manager allows the installation of a given software, it is built from source if a
# SRC_URI is provided.
# Use =/+=/=+ to overwrite the list, _append/_prepend to modify it.
# Default: pip, a package manager available almost everywhere.
DISTRO_PKG_PROVIDERS ?= "pip"

# Space-separated list of packages to install on the given distribution.
# Use =/+=/=+ to overwrite the list, _append/_prepend to modify it.
# Default: all the packages I regularly use on all environments.
PKG_INSTALL ?= "base-files vim vscode ssh git diff-so-fancy bash zsh cmake gcc gdb gdb-dashboard make clang-format clang-tidy clang"
