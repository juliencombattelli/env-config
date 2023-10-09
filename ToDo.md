- [ ] Add an option to disable sudo operations
- [ ] Generate the file hierarchy in a dedicated directory, then deploy into the filesystem
  - => No hardcoded path in recipe
    - [ ] Sanitize-path script to detect hardcoded paths
  - => Deploy main target with an rsync to the global filesystem (handle backup of modified files)
    - [ ] Deploy main target
    - [ ] Backup handling
    - [ ] Uninstall main target reverting to a known backup

WON'T DO
- [-] Replace the PKG_PROVIDER mechanism with the native PROVIDES/PREFERRED_PROVIDER providers handling for virtual packages
  - /!\ Won't do: PROVIDES only impacts which recipe get selected by BitBake and cannot be used to impact other recipes task-wise
  - [-] Create virtual/packagemanager that each current pkg mgr PROVIDES
  - [-] Set PREFERRED_PROVIDER_virtual/packagemanager where appropriate (mainly in distro files)
