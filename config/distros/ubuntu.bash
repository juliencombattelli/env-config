# Use Apt as main package provider on Ubuntu
EC_DISTRO_PKG_PROVIDERS+=(apt pip)

EC_PKG_PROVIDER_apt_PKG_PATTERN[clang]='^clang-[0-9.]+$'
EC_PKG_PROVIDER_apt_PKG_PATTERN[clang-format]='^clang-format-[0-9.]+$'
EC_PKG_PROVIDER_apt_PKG_PATTERN[clang-tidy]='^clang-tidy-[0-9.]+$'
EC_PKG_PROVIDER_apt_PKG_PATTERN[ninja]='^ninja-build$'
EC_PKG_PROVIDER_apt_PKG_PATTERN[fd]='^fd-find$'
EC_PKG_PROVIDER_apt_PKG_PATTERN[ccmake]='^cmake-curses-gui$'
