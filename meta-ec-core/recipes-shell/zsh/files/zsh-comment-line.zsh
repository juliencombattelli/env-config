function jucom-comment-line() {
    if [[ "$BUFFER[1]" == "#" ]]; then
        BUFFER="$BUFFER[2,-1]"
    else
        BUFFER="#$BUFFER"
    fi
}
zle -N jucom-comment-line

# FIXME This seems to reset the last arg history using the Alt+. shortcut
bindkey $'^_' jucom-comment-line

