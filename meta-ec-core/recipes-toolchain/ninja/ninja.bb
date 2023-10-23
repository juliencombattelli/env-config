DESCRIPTION = ""
PN = "ninja"
PV = "1"

inherit installable

EXCLUDELIST_PKG_PROVIDERS_${PN}:remove = "pip"
