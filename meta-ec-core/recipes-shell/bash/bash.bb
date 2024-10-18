DESCRIPTION = ""
PN = "bash"
PV = "1"

DEPENDS += "shell-common dircolors"

inherit installable

SRC_URI += "file://fragment.bashrc"

do_configure() {
    bbplain "Configuring bash."

    bbplain "Updating bashrc."
    sed -i "s|@EC_TARGET_INSTALL_DIR@|${EC_TARGET_INSTALL_DIR}|g" "${WORKDIR}/fragment.bashrc"
    ec_update_file_with_fragment "${HOME}/.bashrc" "${WORKDIR}/fragment.bashrc"
}
