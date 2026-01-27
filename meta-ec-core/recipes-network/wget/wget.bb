DESCRIPTION = ""
PN = "wget"
PV = "1"

SRC_URI += "file://wgetrc file://wget.sh"

do_configure() {
    bbplain "Configuring wget."

    mkdir -p "${HOME}/.config/wget"
    cp "${WORKDIR}"/wgetrc "${HOME}/.config/wget"

    cp "${WORKDIR}"/wget.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
