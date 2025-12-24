source $EC_LAYER_DIR/distros/default.bash

DISTRO_PKG_PROVIDERS=("apt" "${DISTRO_PKG_PROVIDERS[@]}")

# TODO Fish does not support - in identifiers => use JSON?
# set PKG_PROVIDER_apt_PACKAGE_PATTERN_clang '^clang-[0-9.]+$'
# set PKG_PROVIDER_apt_PACKAGE_PATTERN_clang-format '^clang-format-[0-9.]+$'
# set PKG_PROVIDER_apt_PACKAGE_PATTERN_clang-tidy '^clang-tidy-[0-9.]+$'
# set PKG_PROVIDER_apt_PACKAGE_PATTERN_ninja '^ninja-build$'
# set PKG_PROVIDER_apt_PACKAGE_PATTERN_fd '^fd-find$'

ALIAS_bat="batcat"
ALIAS_fd="fdfind"
ALIAS_ls="eza"
ALIAS_ll="eza -lg"
ALIAS_la="eza -lag"
