#!/bin/sh

function _repo_is_workspace {
    # Check if the given directory is a repo workspace
    local current_dir="$1"
    local folders_to_check=(.repo)
    for folder in ${folders_to_check[@]}; do
        if [ ! -d "$current_dir/$folder" ]; then
            return 1
        fi
    done
    return 0
}

function _repo_look_for_workspace {
    # Walk through parent directories until a repo workspace is found
    local current_dir="${1:=$(pwd)}"
    if [[ "$current_dir" != /home/$USER/* ]]; then
        return 1
    fi
    if _repo_is_workspace "$current_dir"; then
        echo "$current_dir"
        return 0
    fi
    local parent_dir="$(dirname $current_dir)"
    _repo_look_for_workspace "$parent_dir"
}

function _repo_cd_parent_workspace {
    cd $(_repo_look_for_workspace)
    return $?
}

alias cdw="_repo_cd_parent_workspace"
