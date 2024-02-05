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

    install -m 0755 "${WORKDIR}"/which-distro "${EC_TARGET_INSTALL_DIR}"/bin/
    install -m 0755 "${WORKDIR}"/which-platform "${EC_TARGET_INSTALL_DIR}"/bin/
    install -m 0755 "${WORKDIR}"/timestamp "${EC_TARGET_INSTALL_DIR}"/bin/

    cp "${WORKDIR}"/00_lang.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp "${WORKDIR}"/00_path.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp "${WORKDIR}"/00_term.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
