DESCRIPTION = ""
PN = "x11fwd"
PV = "1"

SRC_URI = "file://files"

do_configure() {
    bbplain "Configuring X11 fowarding"
    mkdir -p "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    cp -r "${WORKDIR}"/files/. "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
    sed -i "s^@X11_DISPLAY@^${X11_DISPLAY}^g" ${EC_TARGET_INSTALL_DIR}/etc/profile.d/x11display.sh
}
