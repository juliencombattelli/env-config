DESCRIPTION = "Create a XDG base directory for the current user"
PN = "xdg-dirs"
PV = "1"

do_configure() {
    bbplain "Creating ~/.local base directory."
    mkdir -p $HOME/.local/{bin,share,state}

    bbplain "Creating ~/.cache base directory."
    mkdir -p $HOME/.cache

    bbplain "Creating ~/.config base directory."
    mkdir -p $HOME/.config
}
