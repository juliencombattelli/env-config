PKG_INSTALL_append = " wt powershell x11fwd"

# Those packages must be installed from Windows
PREFERRED_PKG_PROVIDERS_wt = ""
PREFERRED_PKG_PROVIDERS_powershell = ""

# Zsh<5.8 has a bug on WSL leading to orphan processes
PREFERRED_PKG_VERSION_zsh = ">=5.8"
