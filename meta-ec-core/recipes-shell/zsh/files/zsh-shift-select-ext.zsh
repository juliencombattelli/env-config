# Kill the selection region, switch back to the main keymap and process the
# typed keys again.
function shift-select::kill-and-input() {
        zle kill-region -w
        zle -K main
        # Push the typed keys back to the input stack, i.e. process them again,
        # but now with the main keymap.
        zle -U "$KEYS"
}
zle -N shift-select::kill-and-input

# Bind ASCII visible chars to kill-and-input.
bindkey -M shift-select -R ' '-'~' shift-select::kill-and-input
# Bind French-keyboard keys to kill-and-input.
bindkey -M shift-select 'à' shift-select::kill-and-input
bindkey -M shift-select 'é' shift-select::kill-and-input
bindkey -M shift-select 'ù' shift-select::kill-and-input
bindkey -M shift-select 'ç' shift-select::kill-and-input
bindkey -M shift-select 'µ' shift-select::kill-and-input
bindkey -M shift-select '§' shift-select::kill-and-input
bindkey -M shift-select '£' shift-select::kill-and-input
bindkey -M shift-select '¤' shift-select::kill-and-input
bindkey -M shift-select '€' shift-select::kill-and-input
bindkey -M shift-select '²' shift-select::kill-and-input
bindkey -M shift-select '¨' shift-select::kill-and-input
