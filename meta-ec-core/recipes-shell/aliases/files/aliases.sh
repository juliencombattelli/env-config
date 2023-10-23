#!/bin/sh

function define_alias {
    local alias_name="$1"
    shift
    local alias_command=("$@")
    if which "${alias_command[1]}" &>/dev/null; then
        alias "$alias_name"="${alias_command[*]}"
    fi
}

# Aliases
