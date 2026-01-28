DESCRIPTION = ""
PN = "xterm"
PV = "1"

SRC_URI += " file://xterm-set-title "

do_configure() {
    install -m 0755 "${WORKDIR}"/xterm-set-title "${EC_BIN_DIR}"
}
