DESCRIPTION = ""
PN = "shell-common"
PV = "1"

SRC_URI = "file://lang.sh file://path.sh file://term.sh"

do_configure() {
    bbplain "Configuring common shell files."

    cp "${WORKDIR}"/lang.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp "${WORKDIR}"/path.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp "${WORKDIR}"/term.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
