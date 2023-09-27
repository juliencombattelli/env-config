# env-config

**env-config** contains the configuration for my development environment.
Based on BitBake, it provides an easy way to be installed and extended.

## Foreword

Although env-config uses BitBake, this is *NOT* a Yocto-related project.
Some tasks may have names usually used in Yocto (like do_install, do_configure) but have a different meaning.
Here is a non-exhaustive list of tasks with their role:
* do_build_recipe: The default task for all recipes. This task depends on all other normal tasks required to build a recipe.
* do_fetch: Fetch the files needed to build the recipe.
* do_install: Install the software provided by the recipe.
* do_configure: Perform initial configuration of the software provided by the recipe (like deploying *rc files).

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