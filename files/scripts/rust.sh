export RUSTUP_HOME="$HOME/.local/share/rustup"
export CARGO_HOME="$HOME/.local/share/cargo"

if [ -e "$HOME/.local/share/cargo/bin" ]; then
    export PATH="$HOME/.local/share/cargo/bin:$PATH"
fi
