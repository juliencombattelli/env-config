DESCRIPTION = ""
PN = "repo-aliases"
PV = "1"

SRC_URI += "file://repo-aliases.sh"

do_configure() {
    bbplain "Configuring repo aliases."
    cp "${WORKDIR}"/repo-aliases.sh "${EC_INSTALL_DIR}"
}
