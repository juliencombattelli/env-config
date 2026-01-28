DESCRIPTION = ""
PN = "git"
PV = "1"

inherit installable

do_configure() {
    bbplain "Configuring git."
    mkdir -p "${EC_CONFIG_DIR}/git"
    if [ -f "$HOME/.gitconfig" ]; then
        mv "$HOME/.gitconfig" "${EC_CONFIG_DIR}/git/config"
    else
        touch "${EC_CONFIG_DIR}/git/config"
    fi
    git config --global user.email "julien.combattelli@gmail.com"
    git config --global user.name "Julien Combattelli"
    git config --global color.ui "always"
}
