# Changelog

This page summarizes the significant changes that caused compatibility issues
with layers that depend on meta-ec-core.

Refer to the [Yocto Migration Guides](https://docs.yoctoproject.org/dev/migration-guides/migration-general.html)
for instructions on how to adapt to breaking changes from BitBake/Yocto.

Checkout the [Yocto Release page](https://wiki.yoctoproject.org/wiki/Releases)
to get the mapping of BitBake versions, Yocto versions and Yocto codenames.

## Version 1

Initial version.

## Version 2

Based on BitBake 1.52 (Yocto 3.4 Honister):
* override operator changed from `_` to `:`

## Version 3 (planned)

Based on BitBake 2.2 (Yocto 4.1 Langdale)

## Version 4 (planned)

Based on *latest* BitBake 2.4 (Yocto 4.2 Mickledore) or greater
* requires Python 3.8+, thus EC support for Ubuntu 18.04 will reach end of life
