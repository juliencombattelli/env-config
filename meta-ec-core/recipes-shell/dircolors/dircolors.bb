DESCRIPTION = ""
PN = "dircolors"
PV = "1"

SRC_URI += "file://dircolors file://dircolors.sh file://dircolors.zsh"

do_configure() {
    cp "${WORKDIR}"/dircolors "${EC_INSTALL_DIR}"
    cp "${WORKDIR}"/dircolors.sh "${EC_INSTALL_DIR}"
    cp "${WORKDIR}"/dircolors.zsh "${EC_INSTALL_DIR}"
}
