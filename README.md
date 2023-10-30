# env-config

**env-config** contains the configuration for my development environment.
Based on BitBake, it provides an easy way to be installed and extended.

## Foreword

Although env-config uses BitBake, this is *NOT* a Yocto-related project.
Some tasks may have names usually used in Yocto (like do_install, do_configure) but have a different meaning.
Here is a non-exhaustive list of tasks with their role:
* do_start: The first task executed for all recipes.
* do_fetch: Fetch the files needed to build the recipe.
* do_install: Install the software provided by the recipe.
* do_configure: Perform initial configuration of the software provided by the recipe (like deploying *rc files).
* do_complete: The default and last task for all recipes. This task depends on all other normal tasks required to build a recipe.

As a reference, here is a link to the
[BitBake documentation](https://docs.yoctoproject.org/bitbake/2.2/singleindex.html)
currently used.

## Quick start

To install the environment, download this meta-layer and all other layers
needed, and run the following commands:

```bash
# Temporarily disable password authentication for sudo to run system commands from BitBake (like apt)
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null && sudo chmod 0440 /etc/sudoers.d/$USER
# Source the env-config init script
source ./ec-init-build-env
# Run BitBake to perform the software installation and configuration
bitbake all
# Restore the password authentication for sudo
sudo rm /etc/sudoers.d/$USER
```

The setup script ec-init-build-env supports some options (like proxy server).
Run `source ./ec-init-build-env --help` to check them out.

### Configuration

Some options might be adjusted in the generated conf/local.conf file after
sourcing the ec-init-build-env script. They are documented directly in this
local.conf file.

### Installation results

Packages will be installed with the appropriate package manager considering the
current distribution, platform and required version, and there configuration
will be deployed in appropriate places.

Additional configuration files and scripts specific to env-config will be
deployed to ~/.env-config by default. This directory follows the XDG Base
Directory Specification and Filesystem Hierarchy Standard, meaning the user will
find eg. a bin, etc, and share directories inside.

### Note about sudo

As shown above, env-config may need administrator privileges. However, due to
BitBake design, it will not prompt the user for a password when using sudo. To
work around this issue, it is recommended to temporarily disable password
authentication for the user by setting the NOPASSWD option in a sudoers file in
/etc/sudoers.d/ directory. Once the installation of env-config is completed,
remove this sudoers file.

WARNING: try to minimize the operations done in super user as it can be
destructive.

On systems where sudo is not available (either not installed or where the user
is not in the sudoers), sudo operations will be automatically disabled.

## Testing

Tests are mostly performed on WSL Ubuntu distributions (the latest) and inside
docker containers based on the supported Ubuntu distributions. Docker is often
preferred as it will not break the host system in case of error.

To test env-config from an Ubuntu 22.04 container, use docker compose:
```shell
docker compose -f ./docker/docker-compose.yml run --build ec-ubuntu2204
```

Once inside the container, the env-config directory will be bind mounted and you
will be automatically placed inside it. The user will be named `user` and will
be part of the sudoers without password authentication required, thus no need to
manually create the file /etc/sudoers.d/user.

Just source the setup script and run BitBake to test your recipes:
```shell
source ./ec-init-build-env
bitbake <recipe>
```
