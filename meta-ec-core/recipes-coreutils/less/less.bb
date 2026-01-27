DESCRIPTION = ""
PN = "less"
PV = "1"

inherit installable

SRC_URI += "file://less.sh"

do_configure() {
    bbplain "Configuring less."

    cp "${WORKDIR}"/less.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/

    if [ -f "$HOME/.lesshst" ]; then
        bbplain "Moving existing less history file: ~/.lessht -> ~/.local/state/less/history"
        mkdir -p "$HOME/.local/state/less"
        mv "$HOME/.lesshst" "$HOME/.local/state/less/history"
    fi
}
