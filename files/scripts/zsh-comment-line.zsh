function jucom-comment-line() {
    if [[ "$BUFFER[1]" == "#" ]]; then
        BUFFER="$BUFFER[2,-1]"
    else
        BUFFER="#$BUFFER"
    fi
}
zle -N jucom-comment-line

# For some weird historical BS, both Ctrl+_ and Ctrl+/ send '^_' on Linux using
# an AZERTY keyboard
bindkey $'^_' jucom-comment-line
