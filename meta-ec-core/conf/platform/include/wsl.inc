PKG_INSTALL:append = " wt powershell oh-my-posh x11fwd"

# Zsh<5.8 has a bug on WSL leading to orphan processes
PREFERRED_PKG_VERSION_zsh = ">=5.8"
