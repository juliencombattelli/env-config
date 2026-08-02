if command -v starship &>/dev/null; then
    export ZLE_RPROMPT_INDENT=0
    export STARSHIP_CONFIG=~/.config/starship/starship.toml
    eval "$(starship init zsh)"
fi
