DESCRIPTION = ""
PN = "git"
PV = "1"

inherit installable

do_configure() {
    bbplain "Configuring git."
    mkdir -p "$HOME/.config/git"
    if [ -f "$HOME/.gitconfig" ]; then
        mv "$HOME/.gitconfig" "$HOME/.config/git/config"
    else
        touch "$HOME/.config/git/config"
    fi
    git config --global user.email "julien.combattelli@gmail.com"
    git config --global user.name "Julien Combattelli"
    git config --global color.ui "always"
}
