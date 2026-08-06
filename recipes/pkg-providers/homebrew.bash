EC_DEPENDS+=(wget)

function ec_do_install {
    wget --directory-prefix="$D" --no-verbose --timestamping \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
    
    NONINTERACTIVE=1 bash "$D/install.sh"
}
