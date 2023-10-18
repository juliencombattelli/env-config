TO DO
- [x] Split base-files into multiple recipes
- [x] Add an option to disable sudo operations
- [x] Add PKG_PROVIDER_<pkgprov>_IGNORE_PACKAGE_PATTERN_<pkg> variable to ignore package name for a package manager
      Implemented as EXCLUDELIST_PKG_PROVIDERS_<pkg> for now
- [ ] Check if binary is in path with appropriate version before installing it
- [x] Add support for docker containers and GCP
- [x] Add DISABLE_PKG_PROVIDERS_UPDATE option
- [x] Document settings in README (mostly point to the generated conf/local.conf)

To EVALUATE
- [ ] Evaluate if PKG_PROVIDER_<pkgprov>_IGNORE_PACKAGE_PATTERN_<pkg> is still relevant
- [ ] Generate the file hierarchy in a dedicated directory, then deploy into the filesystem
  - => No hardcoded path in recipe
    - [ ] Sanitize-path script to detect hardcoded paths
  - => Deploy main target with an rsync to the global filesystem (handle backup of modified files)
    - [ ] Deploy main target
    - [ ] Backup handling
    - [ ] Uninstall main target reverting to a known backup
  - => How to handle installed packages???

WON'T DO
- [-] Replace the PKG_PROVIDER mechanism with the native PROVIDES/PREFERRED_PROVIDER providers handling for virtual packages
  - /!\ Won't do: PROVIDES only impacts which recipe get selected by BitBake and cannot be used to impact other recipes task-wise
  - [-] Create virtual/packagemanager that each current pkg mgr PROVIDES
  - [-] Set PREFERRED_PROVIDER_virtual/packagemanager where appropriate (mainly in distro files)
