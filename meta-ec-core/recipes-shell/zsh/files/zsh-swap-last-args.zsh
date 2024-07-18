function jucom-swap-last-args() {
    autoload -Uz split-shell-arguments

    local -a reply
    split-shell-arguments

    integer arg_index=-2 # Start from last
    # FIXME last should be -1, but reply[-1] seems to always be an empty string?!

    # Find the index of the last argument
    while [[ ${reply[arg_index]} = [[:space:]]* ]]; do
        (( arg_index-- ))
    done
    integer last_arg_index=$(( arg_index-- ))

    # Find the index of the before last argument
    while [[ ${reply[arg_index]} = [[:space:]]* ]]; do
        (( arg_index-- ))
    done
    integer before_last_arg_index=$(( arg_index-- ))

    # Swap the two last arguments
    tmp=$reply[before_last_arg_index]
    reply[before_last_arg_index]=$reply[last_arg_index]
    reply[last_arg_index]=$tmp

    # Set the zle BUFFER with the swapped command line
    BUFFER=${(j::)reply}
}
zle -N jucom-swap-last-args

bindkey $'^T' jucom-swap-last-args

