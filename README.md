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
[Bitbake documentation](https://docs.yoctoproject.org/bitbake/1.52/singleindex.html)
currently used.

## Quick start

To install the environment, download this meta-layer and all other layers needed, and run the following commands:
```bash
# Temporarily disable password authentication for sudo to run system commands from BitBake (like apt)
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null && sudo chmod 0440 /etc/sudoers.d/$USER
# Source the env-config init script
source ./ec-init-build-env
# Run bitbake to perform the software installation and configuration
bitbake all
# Restore the password authentication for sudo
sudo rm /etc/sudoers.d/$USER
```

As shown above, env-config may need administrator privileges.
However, due to BitBake design, it will not prompt the user for a password when using sudo.
To work around this issue, it is recommended to temporarily disable password authentication
for the user by setting the NOPASSWD option in a sudoers file in /etc/sudoers.d/ directory.
Once the installation of env-config is completed, remove this sudoers file.
WARNING: try to minimize the operations done in super user as it can be destructive.
