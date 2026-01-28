DESCRIPTION = ""
PN = "shell-common"
PV = "1"

FILESPATH:prepend := "${ECROOT}/meta-ec-core/scripts:"

SRC_URI += " \
    file://which-distro file://which-platform file://timestamp \
    file://00_lang.sh file://00_path.sh file://00_term.sh \
"

do_configure() {
    bbplain "Configuring common shell files."

    install -m 0755 "${WORKDIR}"/which-distro "${EC_BIN_DIR}"
    install -m 0755 "${WORKDIR}"/which-platform "${EC_BIN_DIR}"
    install -m 0755 "${WORKDIR}"/timestamp "${EC_BIN_DIR}"

    cp "${WORKDIR}"/00_lang.sh "${EC_INSTALL_DIR}"
    cp "${WORKDIR}"/00_path.sh "${EC_INSTALL_DIR}"
    cp "${WORKDIR}"/00_term.sh "${EC_INSTALL_DIR}"
}
