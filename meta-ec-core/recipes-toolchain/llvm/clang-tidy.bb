DESCRIPTION = ""
PN = "clang-tidy"
PV = "1"

PKG_PROVIDER_apt_PACKAGE_PATTERN_${PN} = "clang-tidy-[0-9.]+"

inherit installable

# TODO deploy default clang-tidy
