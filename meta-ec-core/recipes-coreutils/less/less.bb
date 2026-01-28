DESCRIPTION = ""
PN = "less"
PV = "1"

inherit installable

SRC_URI += "file://less.sh"

do_configure() {
    bbplain "Configuring less."

    cp "${WORKDIR}/less.sh" "${EC_INSTALL_DIR}"

    if [ -f "$HOME/.lesshst" ]; then
        bbplain "Moving existing less history file: ~/.lessht -> ${EC_STATE_DIR}/less/history"
        mkdir -p "${EC_STATE_DIR}/less"
        mv "$HOME/.lesshst" "${EC_STATE_DIR}/less/history"
    fi
}
