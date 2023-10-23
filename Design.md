## Global configuration

Options that should only be defined in bitbake.conf or conf/local.conf:

* PLATFORM:
  - supported: native, virtualmachine, wsl1, wsl2, containerdocker

* DISTRO:
  - supported: Ubuntu1804, Ubuntu2004, Ubuntu2204, KdeNeon
  - planned: Manjaro, Cygwin, MSYS2, Windows
  - no longer supported: Ubuntu1604

* DISABLE_SUDO: disable all operations requiring the use of sudo.
  Use case: needed on platforms where root access might be restricted (eg.
    GCP when CLOUD_WORKSTATIONS_CONFIG_DISABLE_SUDO is true).
Note: sudo operations in all recipes must use special functions automatically
  checking this flag. Sudo must never be used directly.

* DISABLE_PKG_PROVIDERS_UPDATE: disable update operations of package providers.
  Use case: have a shorter develop/run/debug loop.

### PLATFORM configuration

Options that should only be defined in a platform config file:

* PLATFORM_FEATURES: features enabled for the given platform
  - native:
  - virtualmachine: ssh-server
  - WSL1:
  - WSL2:
  - containerdocker:

* PLATFORM_EXTRA_FEATURES:
  - native:
  - virtualmachine: x11fwd
  - WSL1: x11fwd
  - WSL2: x11fwd(? may not be needed with WSLg)

Note: those variables do not exist and are implemented using PKG_INSTALL or
  other specific variables.

### DISTRO configuration

Options that should only be defined in a distro config file:

* DISTRO_COMPATIBLE_PLATFORMS (this variable does not exist and is here only
  for reference).
  - ~~Ubuntu1604: native, virtualmachine, wsl1, wsl2, containerdocker~~
  - Ubuntu1804: native, virtualmachine, wsl1, wsl2, containerdocker
  - Ubuntu2004: native, virtualmachine, wsl1, wsl2, containerdocker
  - Ubuntu2204: native, virtualmachine, wsl1, wsl2, containerdocker
  - KdeNeon: native, virtualmachine
  - Manjaro: native, virtualmachine
  - Cygwin: native
  - MSYS2: native
  - Windows: native

* DISTRO_PKG_PROVIDERS: list of package manager to use by priority order
  (syspkgmgr > pip > built from source).
  - pip: all
  - apt: Ubuntu-based (Ubuntu1604, Ubuntu1804, Ubuntu2004, KdeNeon)
  - pacman: Arch-based (Manjaro, MSYS2)
  - winget: Windows
  - powershell install-package: Windows
  - none: package built from source

### Recipes configuration

Options that may be defined in a config file, a class or a recipe:

* PREFERRED_PKG_PROVIDERS_<pkg>: overrides the DISTRO_PACKAGE_MANAGERS priority
  list for a particular pkg and use the specified pkgmanagers.
  Use case: zsh-syntax-highlight is available with a git clone or via apt
    (actually not relevant for zsh-syntax-highlight as git repo are handled with
    bb.fetch2).

~~Note: On Ubuntu-based distro, for cmake pip is preferred and~~
  ~~PREFERRED_PKG_PROVIDER_cmake will be set accordingly. But ccmake (curses gui)~~
  ~~is not available on pip (yet) and is required to be installed from apt.~~
Note2: Kitware now provides a PPA for CMake software (including UI add-ons)
  making the note above irrelevant.

* EXCLUDELIST_PKG_PROVIDERS_<pkg>: ignore the given package providers for the
  given package.
  Use case: exa and bat are not provided through pip.

* PREFERRED_PKG_VERSION_<pkg>: use a specific version (version range?) for pkg.
  Use case: Zsh<5.8 has a bug in WSL and version 5.8+ must be recompiled...

* PKG_PROVIDER_<pkgprov>_PACKAGE_PATTERN_<pkg>: defines a package name pattern
  for <pkg> to search for using <pkgprov>.
  The pattern syntax depends on what <pkg> supports.
  As an example, apt package provider supports regex, but pip don't.

* PKG_PROVIDER_<pkgprov>_IGNORE_PACKAGE_PATTERN_<pkg>: defines a package name
  pattern for <pkg> that should be ignore when searching the package using
  <pkgprov>. The pattern syntax depends on what <pkg> supports. As an example,
  apt package provider supports regex, but pip don't.
  Use case: pip provides exa which is not related to the ls replacement from
  ogham/exa, or make which is not related to build systems...
  TODO evaluate if this is relevant since EXCLUDELIST_PKG_PROVIDERS_<pkg> is
  already implemented.

* ALIAS[<aliasname>] = "<command>": defines an alias <aliasname> using <command>
  as value. The aliases should be defined in a distro config file as the name of
  the targeted command may be distro-dependant.
  However, for distro-independent aliases, it is preferable to store them in a
  dedicated file deployed in <ec-install-dir>/etc/profile.d
  (cf. recipes-scm/repo/repo-aliases.bb). The alias shell file is generated in
  the base-files recipe.

## Tasks

* Poky workflow:

fetch ─> unpack ─> patch ─> prepare_recipe_sysroot ─> configure ─> compile ─┐
┌───────────────────────────────────────────────────────────────────────────┘
└─> install ─┬─> package          ─┬─> package_write ─> rootfs ─> image
             ├─> packagedata      ─┤
             └─> populate_sysroot ─┘

* EC generic workflow:

start ─> fetch ─> install ─> configure ─> complete

  * Some recipes might use other workflows (including compilation steps)
    depending on the needs.
  * Tasks start and complete are defined in the base class but should not be
    overridden. Ideally they should be marked noexec but since they are using
    pre/postfuncs it would inhibit those callbacks too...
  * Errors while compiling, installing or configuring a package should not be
    fatal, unless the error can have side effects on the system. As an example
    if neovim is compiled, a set of dependency must be manually installed; the
    absence of those dependencies should emit an non-fatal error logged in
    console which does not interrupt the BitBake run. However, a permission
    error while copying a file may come from a wrong configuration at distro or
    platform level, and should stop immediately BitBake before damaging the
    system.

* Task `showdata`: show the environment of a recipe (similar to bitbake -e).

* Task `listtasks`: list the tasks of a recipe and their flags.

## Recipes

* Recipe `all`: install all recipes registered in PKG_INSTALL variable and their
  dependencies.

* System configuration: do tasks reserved for superusers (not supported directly
  by BitBake in normal user...).
  - ~~for now: bitbake generate_system_install_script; ./system_install_script.sh~~
    => Impossible to automatically handle dependent tasks with less than 2
      running steps (run BitBake to install user packages and generate the
      script for admin packages, run the script to install admin packages, run
      BitBake again to configure all packages...).
  - ~~prefered: sudo su; bitbake world -c do_system_install~~
    => Don't want to run all BitBake processes in superuser.
  - adopted: use NOPASSWD attribute in a temporary sudoers file (see README).

* Configuration deployment: install and configure software, then deploy the
  configuration files.
  - for now: all recipes directly install their files and software where needed.
    Might be to difficult to handle deployment from a temporary working
    directory. See ToDo for related tasks.

* Configuration cleaning: remove previously installed configuration
  (and uninstall previously installed software?).
  - for now: no uninstallation implemented at all. This would require listing
    all installed software and files, backing up all previously install files,
    and providing a rollback procedure for each types (software: uninstall if
    not breaking the system, files: restore backed up version or remove). See
    ToDo for related tasks.
