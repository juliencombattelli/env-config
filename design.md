## Global configuration

* PLATFORM (supported: native, virtualmachine, WSL1, WSL2, dockercontainer, gcpworkstation)
* DISTRO (supported: Ubuntu1604, Ubuntu1804, Ubuntu2004, Ubuntu2204, KdeNeon, Manjaro, Cygwin, MSYS2, Windows)

### PLATFORM configuration

* PLATFORM_FEATURES
    - native:
    - virtualmachine: ssh-server
    - WSL1:
    - WSL2:
    - dockercontainer:
    - gcpworkstation:

* PLATFORM_EXTRA_FEATURES
    - native:
    - virtualmachine: x11fwd
    - WSL1: x11fwd
    - WSL2: x11fwd(? may not be needed with WSLg)

### DISTRO configuration

* DISTRO_COMPATIBLE_PLATFORMS
    - Ubuntu1604: native, virtualmachine, WSL1, WSL2
    - Ubuntu1804: native, virtualmachine, WSL1, WSL2
    - Ubuntu2004: native, virtualmachine, WSL1, WSL2
    - Ubuntu2204: native, virtualmachine, WSL1, WSL2
    - KdeNeon: native, virtualmachine
    - Manjaro: native, virtualmachine
    - Cygwin: native
    - MSYS2: native
    - Windows: native

* DISTRO_PKG_PROVIDERS: list of package manager to use by priority order (syspkgmgr > pip > built from source)
    - pip: all
    - apt: Ubuntu-based (Ubuntu1604, Ubuntu1804, Ubuntu2004, KdeNeon)
    - pacman: Arch-based (Manjaro, MSYS2)
    - winget: Windows
    - powershell install-package: Windows
    - none: package built from source

* PREFERRED_PKG_PROVIDERS_<pkg>: overrides the DISTRO_PACKAGE_MANAGERS priority list for a particular pkg and use the specified pkgmanagers
    - use case: zsh-syntax-highlight is available with a simple git clone or via apt

* EXCLUDELIST_PKG_PROVIDERS_<pkg>: ignore the given package providers for the given package
  - use case: exa and bat are not provided through pip

* PREFERRED_PKG_VERSION_<pkg>: use a specific version (version range?) for pkg
    - use case: Zsh<5.8 has a bug in WSL and version 5.8+ must be recompiled...

Note: On Ubuntu-based distro, for cmake pip is preferred and PREFERRED_PKG_PROVIDER_cmake will be set accordingly.
      But ccmake (curses gui) is not available on pip (yet) and is required to be installed from apt.

* PKG_PROVIDER_<pkgprov>_PACKAGE_PATTERN_<pkg>: defines a package name pattern for <pkg> to search for using <pkgprov>
  The pattern syntax depends on what <pkg> supports. As an example, apt package provider supports regex, but pip don't.

* PKG_PROVIDER_<pkgprov>_IGNORE_PACKAGE_PATTERN_<pkg>: defines a package name pattern for <pkg> that should be ignore when searching the package using <pkgprov>
  The pattern syntax depends on what <pkg> supports. As an example, apt package provider supports regex, but pip don't.
  - use case: pip provides exa which is not related to the ls replacement from ogham/exa
  - TODO evaluate if this is relevant sinceEXCLUDELIST_PKG_PROVIDERS_<pkg> is already implemented

* ALIAS[<aliasname>] = "<command>": defines an alias <aliasname> using <command> as value.
  The aliases should be defined in a distro config file as the name of the targeted
  command may be distro-dependant.
  However, for distro-independent aliases, it is preferable to store them in a dedicated file deployed in
  <ec-install-dir>/etc/profile.d (cf. recipes-scm/repo/repo-aliases.bb).
  The alias shell file is generated in the base-files recipe.

* DISABLE_SUDO: disables all operations requiring the use of sudo.
  - use case: needed on platforms where root access might be restricted (eg. GCP when CLOUD_WORKSTATIONS_CONFIG_DISABLE_SUDO is true).
Note: sudo operations in all recipes should use special functions automatically checking this flag. Sudo should never be used directly.

## Tasks

* Poky workflow:
fetch -> unpack -> patch -> prepare_recipe_sysroot -> configure -> compile -> install -> package          -> package_write -> rootfs -> image
                                                                                      |> packagedata      |
                                                                                      |> populate_sysroot |

* EC generic workflow:
start -> fetch -> install -> configure -> complete
Some recipes might use other workflows (including compilation steps) depending on the needs

## Recipes

* System configuration: do tasks reserved for superusers (not supported directly by BitBake in normal user...)
    - for now: bitbake generate_system_install_script; ./system_install_script.sh
    - prefered: sudo su; bitbake world -c do_system_install

* Configuration deployment: install and configure software, then deploy the configuration files
    - bitbake deploy

* Configuration cleaning: remove previously installed configuration (and uninstall previously installed software?)
    - bitbake uninstall
