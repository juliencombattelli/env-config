DESCRIPTION = ""
PN = "clang-format"
PV = "1"

PKG_PROVIDER_apt_PACKAGE_PATTERN_${PN} = "clang-format-[0-9.]+"

inherit installable

# TODO deploy default clang-format
