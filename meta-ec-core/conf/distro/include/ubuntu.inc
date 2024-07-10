# Use Apt as main package provider on Ubuntu
DISTRO_PKG_PROVIDERS:prepend = " apt "

# /!\ Use `^` and `$` to delimit the regexes, otherwise
# `clang-[0-9.]+` could match `clang-15-examples`
PKG_PROVIDER_apt_PACKAGE_PATTERN_clang = "^clang-[0-9.]+$"
PKG_PROVIDER_apt_PACKAGE_PATTERN_clang-format = "^clang-format-[0-9.]+$"
PKG_PROVIDER_apt_PACKAGE_PATTERN_clang-tidy = "^clang-tidy-[0-9.]+$"
PKG_PROVIDER_apt_PACKAGE_PATTERN_ninja = "^ninja-build$"
PKG_PROVIDER_apt_PACKAGE_PATTERN_fd = "^fd-find$"

ALIAS[bat] = "batcat"
ALIAS[fd] = "fdfind"
ALIAS[ls] = "eza"
ALIAS[ll] = "eza -lg"
ALIAS[la] = "eza -lag"
