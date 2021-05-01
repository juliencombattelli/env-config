# env-config

**env-config** contains the configuration for my development environment.
Based on BitBake, it provides an easy way to be installed and extended.


## Quick start

To install the environment, download this meta-layer and all other layers needed, and run the following commands:
```bash
# Temporarily disable password authentication for sudo to run system commands from BitBake (like apt)
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER > /dev/null && sudo chmod 0440 /etc/sudoers.d/$USER
# Source the env-config init script
source ./ec-init-build-env
# Run bitbake to perform the software installation and configuration
bitbake world
# Restore the password authentication for sudo
sudo rm /etc/sudoers.d/$USER
```