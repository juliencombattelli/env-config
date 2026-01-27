# TODO

This file list all considered tasks to implement in env-config. They are
separated in three categories:
- To do (planned tasks ready to be implemented)
- To evaluate (planned tasks with high uncertainty about how to implement them)
- Won't do (unplanned tasks that will not be done)

## TO DO

- [x] Split base-files into multiple recipes
- [x] Add an option to disable sudo operations
- [x] Add PKG_PROVIDER_<pkgprov>_IGNORE_PACKAGE_PATTERN_<pkg> variable to ignore package name for a package manager
      Implemented as EXCLUDELIST_PKG_PROVIDERS_<pkg> for now
- [ ] Check if binary is in path with appropriate version before installing it
      => Not that easy cause we don't know the name of the binaries before hand
         For example we could have clang-16 or -17, so to know if it is installed
         the get_version function should test every clang-* starting with high numbers, not ideal...
- [x] Ensure python3-apt package is available from the first python3 found in
      PATH or fallback to system python which should have it
      => just added exception handling to import apt
- [x] Handle permission denied on copies (.bashrc appears to be ro on some configuration...)
      => handled in other meta-layer for this specific environment
- [x] Add support for docker containers and GCP
- [x] Add DISABLE_PKG_PROVIDERS_UPDATE option
- [x] Document settings in README (mostly point to the generated conf/local.conf)
- [ ] Upgrade bitbake (inclusive language)
  - [x] bitbake 2.2 for python 3.6
  - [ ] bitbake 2.4+ for python 3.8 (no ubuntu1804)
- [x] Upgrade Neovim to 0.10.0
- [x] Add support for Ubuntu 24.04
- [ ] Fetch CMake from cmake.org
- [x] Replace exa with eza fetched from Github releases
- [x] Add EC_DEPRECATED recipe flag
- [x] Remove pip from all distro as package provider
- [x] Mark pip deprecated?
- [ ] Add a "check" recipe issuing a warning if user is not 1000 on WSL (limitation for Wayland w/ WSLg)
- [ ] Add all requirements in README for the current bitbake version (including locale and python3-packaging)
- [ ] Install waypipe (associate with X11fwd?)
- [ ] Create symlink of /mnt/wslg/runtime-dir/wayland-* in /run/user/$UID/
- [ ] Add rust/cargo toolchain recipe
- [ ] Move a maximum of files out of $HOME into dedicated XDG folders (.config, .local, .cache)
  - [x] bash
  - [x] zsh
  - [x] git
  - [x] gdb
  - [ ] tmux config
  - [ ] docker
  - [ ] repo folders
  - [ ] less history
  - [x] wget hsts
  - [ ] python history
  - [ ] rust/cargo
  - [x] vim (delete as nvim is used by default now?)
  - [ ] vscode folders (not sure if this is doable)
  - [ ] .cmake
  - [ ] .landscape (wtf is this?)
  - [ ] .dotnet (needed only for that CMake VSCode extension...)
  - [ ] .dbus (wtf they don't respect their own XDG spec...)
  - [ ] env-config (should be in .config/env-config)

## TO EVALUATE

- [ ] Evaluate if PKG_PROVIDER_<pkgprov>_IGNORE_PACKAGE_PATTERN_<pkg> is still relevant
- [ ] Generate the file hierarchy in a dedicated directory, then deploy into the filesystem
  - => No hardcoded path in recipe
    - [ ] Sanitize-path script to detect hardcoded paths
  - => Deploy main target with an rsync to the global filesystem (handle backup of modified files)
    - [ ] Deploy main target
    - [ ] Backup handling
    - [ ] Uninstall main target reverting to a known backup
  - => How to handle installed packages???

## WON'T DO

- [ ] Replace the PKG_PROVIDER mechanism with the native PROVIDES/PREFERRED_PROVIDER providers handling for virtual packages
  - /!\ Won't do: PROVIDES only impacts which recipe get selected by BitBake and cannot be used to impact other recipes task-wise
  - [ ] Create virtual/packagemanager that each current pkg mgr PROVIDES
  - [ ] Set PREFERRED_PROVIDER_virtual/packagemanager where appropriate (mainly in distro files)
- [ ] Use classes to implement pkg-providers
      => Not doable as it would require passing function arguments through environment variables...
