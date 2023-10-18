DESCRIPTION = ""
PN = "requests-ca-bundle"
PV = "1"

SRC_URI += "file://requests-ca-bundle.sh"

do_configure() {
    bbplain "Configuring Python Requests CA bundle script."
    cp "${WORKDIR}"/requests-ca-bundle.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
