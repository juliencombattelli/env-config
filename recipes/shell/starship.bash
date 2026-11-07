function ec_do_install {
    wget --directory-prefix="$(realpath --relative-to=. "$D")" --no-verbose --timestamping https://starship.rs/install.sh
    sh "$D/install.sh" --yes --bin-dir "$HOME/.local/bin"
}
