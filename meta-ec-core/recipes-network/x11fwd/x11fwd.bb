DESCRIPTION = ""
PN = "x11fwd"
PV = "1"

SRC_URI += "file://files"

do_configure() {
    bbplain "Configuring X11 fowarding"
    cp -r "${WORKDIR}"/files/. "${EC_INSTALL_DIR}"
    sed -i "s^@X11_DISPLAY@^${X11_DISPLAY}^g" "${EC_INSTALL_DIR}"/x11display.sh
}
