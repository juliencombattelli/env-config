# Kill the selection region, switch back to the main keymap and process the
# typed keys again with the main keymap
function shift-select::jucom-kill-and-input() {
    zle kill-region -w
    zle -K main
    zle -U -- "$KEYS"
}
zle -N shift-select::jucom-kill-and-input

# Bind ASCII visible chars to kill-and-input
bindkey -M shift-select -R ' '-'~' shift-select::jucom-kill-and-input
# Bind French-keyboard keys to kill-and-input
bindkey -M shift-select 'à' shift-select::jucom-kill-and-input
bindkey -M shift-select 'é' shift-select::jucom-kill-and-input
bindkey -M shift-select 'ù' shift-select::jucom-kill-and-input
bindkey -M shift-select 'ç' shift-select::jucom-kill-and-input
bindkey -M shift-select 'µ' shift-select::jucom-kill-and-input
bindkey -M shift-select '§' shift-select::jucom-kill-and-input
bindkey -M shift-select '£' shift-select::jucom-kill-and-input
bindkey -M shift-select '¤' shift-select::jucom-kill-and-input
bindkey -M shift-select '€' shift-select::jucom-kill-and-input

# Handle copy/cut/paste to/from system clipboard
# Based on https://unix.stackexchange.com/questions/634765/copying-text-with-ctrl-c-when-the-zsh-line-editor-is-active

# precmd hook to disable Ctrl+C interrupt
function zle-jucom-disable-ctrl-c {
    # We are now in buffer editing mode
    # Clear the interrupt combo Ctrl+C by setting it to the null character,
    # so it can be used as the copy-to-clipboard key instead
    stty -F /dev/tty intr "^@"
}
precmd_functions=("zle-jucom-disable-ctrl-c" ${precmd_functions[@]})

# preexec hook to restore Ctrl+C interrupt
function zle-jucom-enable-ctrl-c {
    # We are now out of buffer editing mode
    # Restore the interrupt combo Ctrl+C
    stty -F /dev/tty intr "^C"
}
preexec_functions=("zle-jucom-enable-ctrl-c" ${preexec_functions[@]})

# Bind Ctrl+C to copy to CUTBUFFER and system clipboard using OSC52 escape sequence
function shift-select::jucom-copy() {
    zle copy-region-as-kill
    printf "\e]52;c;$(echo -n "${CUTBUFFER}" | base64)\a"
    zle deactivate-region -w
    zle -K main
}
zle -N shift-select::jucom-copy
bindkey -M shift-select $'^C' shift-select::jucom-copy

# Bind Ctrl+X to cut to CUTBUFFER and system clipboard using OSC52 escape sequence
function shift-select::jucom-copy-and-kill() {
    zle kill-region -w
    printf "\e]52;c;$(echo -n "${CUTBUFFER}" | base64)\a"
    zle -K main
}
zle -N shift-select::jucom-copy-and-kill
bindkey -M shift-select $'^X' shift-select::jucom-copy-and-kill

# Bind Ctrl+V to paste the CUTBUFFER
# Use Ctrl+Shift+V on WT to paste the system clipboard
bindkey $'^V' yank

# Use standard break behavior for Ctrl+C in default keymap
bindkey $'^C' send-break

# Bind Ctrl+A to select all the line
# Based on https://stackoverflow.com/a/68987551/13658418
function shift-select::jucom-select-all() {
    local buflen=$(echo -n "$BUFFER" | wc -m | bc)
    CURSOR=0
    zle set-mark-command
    while [[ $CURSOR < $buflen ]]; do
        zle end-of-line
    done
    zle -K shift-select
}
zle -N shift-select::jucom-select-all
bindkey '^A' shift-select::jucom-select-all

# Rebind Escape+<Arrow> to the same action as <Arrow> to avoid having part of
# the escape sequence printed (will still happen for Escape+Escape+<Arrow>)
bindkey $'^[^[OA' up-line
bindkey $'^[^[OB' down-line
bindkey $'^[^[OC' forward-char
bindkey $'^[^[OD' backward-char
# Reduce the delay after hitting Escape to 100ms
export KEYTIMEOUT=10

# TODO add Ctrl+Z and Ctrl+Y to undo and redo
