# env-config V4

**env-config** contains the configuration for my development environment.
This version is a complete rewrite in Bash compared to env-config V3 that was
using BitBake.

## Prerequisites

Env-config V4 can be fetched with either git or wget:
```
# with git
git clone git@github.com:juliencombattelli/env-config-v4
# with wget
wget https://api.github.com/repos/juliencombattelli/env-config-v4/tarball/main
```

Note that both git and wget are required to fetch dependencies during
environment configuration, so it is recommended to install them manually before
running env-config.
```bash
# On Ubuntu-based distributions
sudo apt install git wget
```
