DESCRIPTION = ""
PN = "wget"
PV = "1"

SRC_URI += "file://wgetrc file://wget.sh"

do_configure() {
    bbplain "Configuring wget."

    mkdir -p "${EC_CONFIG_DIR}/wget"
    cp "${WORKDIR}/wgetrc" "${EC_CONFIG_DIR}/wget/"

    cp "${WORKDIR}/wget.sh" "${EC_INSTALL_DIR}"
}
