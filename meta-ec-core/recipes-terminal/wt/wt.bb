DESCRIPTION = ""
PN = "wt"
PV = "1"

SRC_URI += " \
    file://wt-clean-progress \
    file://wt-set-progress-running \
    file://wt-set-progress-default \
    file://wt-set-progress-error \
    file://wt-set-progress-warning \
"

do_configure() {
    install -m 0755 "${WORKDIR}"/wt-clean-progress "${EC_TARGET_INSTALL_DIR}"/bin/
    install -m 0755 "${WORKDIR}"/wt-set-progress-running "${EC_TARGET_INSTALL_DIR}"/bin/
    install -m 0755 "${WORKDIR}"/wt-set-progress-default "${EC_TARGET_INSTALL_DIR}"/bin/
    install -m 0755 "${WORKDIR}"/wt-set-progress-error "${EC_TARGET_INSTALL_DIR}"/bin/
    install -m 0755 "${WORKDIR}"/wt-set-progress-warning "${EC_TARGET_INSTALL_DIR}"/bin/
}
