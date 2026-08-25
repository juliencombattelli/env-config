function ec_do_install {
    source "$EC_ROOT_DIR/files/scripts/rust.sh"

    echo "Installing rustup"
    wget --directory-prefix="$D" --no-verbose --timestamping https://sh.rustup.rs
    sh "$D/index.html" -y --no-modify-path # index.html... yes... don't ask question
}
