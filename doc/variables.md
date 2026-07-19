# Variables

This documents lists the variables usable in recipe, distro and platform files.

## Read-only variables

Those variables should not be modified from a recipe, distro or platform file.

- EC_ROOT_DIR: absolute path to the root directory of the env-config repo (where the env-config entrypoint script is located).
- EC_DISTRO: current Linux distribution detected. Must be one of `layer-core/distros/*.sh` to be valid.
- EC_PLATFORM: current platform detected. Must be one of `layer-core/platforms/*.sh` to be valid.
- EC_LAYER_CORE_DIR: path to the directory of the core layer.
- EC_LAYER_DIR: absolute path to the root directory of the layer currently processed.
- EC_DISABLE_SUDO: disable usage of sudo if set to a non-empty value
- EC_DISABLE_SUDO_FORCED: set when sudo usage is forcibly disabled because it is not usable in the current environment
- EC_DISABLE_SUDO_FORCED_REASON: store the reason why sudo usage is forcibly disabled

## Output variables

Those variables may be set from a recipe, distro or platform file.

### Variables generally set in distro and platform files

DISTRO_PKG_PROVIDERS
PKG_PROVIDER_<>_PACKAGE_PATTERN_<>
ALIAS_<>

### Variables generally set in recipe files

- EC_DEPENDS: array of packages that are prerequisites to the current package
- EC_CONFIG_LINK_DIR: directory where a symlink to the config folder should be created (default is .config/<pkg-name>)
