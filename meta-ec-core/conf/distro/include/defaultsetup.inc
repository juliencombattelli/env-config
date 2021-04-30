# Space-separated list of package managers to use by descending priority.
# If no package manager allows the installation of a given software, it is built from source if a
# SRC_URI is provided.
DISTRO_PKG_PROVIDERS ?= "pip"