DESCRIPTION = ""
PN = "dircolors"
PV = "1"

SRC_URI += "file://dircolors file://dircolors.sh file://dircolors.zsh"

do_configure() {
    cp "${WORKDIR}"/dircolors "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp "${WORKDIR}"/dircolors.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp "${WORKDIR}"/dircolors.zsh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
