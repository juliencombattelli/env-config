DESCRIPTION = ""
PN = "shell-common"
PV = "1"

FILESPATH:prepend := "${ECROOT}/meta-ec-core/scripts:"

SRC_URI = " \
    file://which-distro file://which-platform \
    file://lang.sh file://path.sh file://term.sh \
"

do_configure() {
    bbplain "Configuring common shell files."

    install -m 0755 "${WORKDIR}"/which-distro "${EC_TARGET_INSTALL_DIR}"/bin/
    install -m 0755 "${WORKDIR}"/which-platform "${EC_TARGET_INSTALL_DIR}"/bin/

    cp "${WORKDIR}"/lang.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp "${WORKDIR}"/path.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp "${WORKDIR}"/term.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
