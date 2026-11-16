function jucom-comment-line() {
    if [[ "$BUFFER[1]" == "#" ]]; then
        local cursor=$CURSOR
        BUFFER="$BUFFER[2,-1]"
        (( CURSOR = cursor > 0 ? cursor - 1 : 0 ))
    else
        local cursor=$CURSOR
        BUFFER="#$BUFFER"
        (( CURSOR = cursor + 1 ))
    fi
}
zle -N jucom-comment-line

# For some weird historical BS, Ctrl+: just sends :, and both Ctrl+_ and Ctrl+/
# send '^_' on Linux using an AZERTY keyboard.
# To make Ctrl+: work the terminal emulator must be configured to send \e[58;5u
# on Ctrl+:, mimicing Kitty keyboard protocol.
bindkey $'^_' jucom-comment-line
bindkey '\e[58;5u' jucom-comment-line
