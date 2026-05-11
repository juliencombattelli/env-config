# Load the select-word-style function without alias expansion
autoload -U select-word-style
# Create a Zle widget from the select-word-style function
zle -N select-word-style
# Bind Alt+z to select word splitting style
bindkey '\ez' select-word-style
# Change default word splitting style to shell tokens (useful to operate on
# shell arguments)
select-word-style shell
