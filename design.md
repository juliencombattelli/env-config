## Global configuration

* PLATFORM (supported: native, virtualmachine, WSL1, WSL2)
* DISTRO (supported: Ubuntu1604, Ubuntu1804, Ubuntu2004, KdeNeon, Manjaro, Cygwin, MSYS2, Windows)

### PLATFORM configuration

* PLATFORM_FEATURES
    - native: 
    - virtualmachine: ssh-server
    - WSL1:
    - WSL2:

* PLATFORM_EXTRA_FEATURES
    - native: 
    - virtualmachine: x11fwd
    - WSL1: x11fwd
    - WSL2: x11fwd(?)

### DISTRO configuration

* DISTRO_COMPATIBLE_PLATFORMS
    - Ubuntu1604: native, virtualmachine, WSL1, WSL2
    - Ubuntu1804: native, virtualmachine, WSL1, WSL2
    - Ubuntu2004: native, virtualmachine, WSL1, WSL2
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

* PREFERRED_PKG_VERSION_<pkg>: use a specific version (version range?) for pkg
    - use case: Zsh<5.8 has a bug in WSL...

Note: On Ubuntu-based distro, for cmake pip is preferred and PREFERRED_PKG_PROVIDER_cmake will be set accordingly.
         But ccmake (curses gui) is not available on pip (yet) and is required to be installed from apt.

## Tasks

* Poky workflow:
fetch -> unpack -> patch -> prepare_recipe_sysroot -> configure -> compile -> install -> package          -> package_write -> rootfs -> image
                                                                                      |> packagedata      |
                                                                                      |> populate_sysroot |
* EC workflow:
    - install        -> configure -> deploy
      system_install |

## Recipes

* System configuration: do tasks reserved for superusers (not supported directly by BitBake in normal user...)
    - for now: bitbake generate_system_install_script; ./system_install_script.sh
    - prefered: sudo su; bitbake world -c do_system_install

* Configuration deployment: install and configure software, then deploy the configuration files
    - bitbake deploy

* Configuration cleaning: remove previously installed configuration (and uninstall previously installed software?)
    - bitbake uninstall
