#!/bin/sh

export WGETRC=~/.config/wget/wgetrc

# Create the cache folder for HSTS storage because wget don't create it...
mkdir -p "$HOME/.cache/wget"
