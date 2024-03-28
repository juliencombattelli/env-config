DESCRIPTION = ""
PN = "proxy"
PV = "1"

SRC_URI += "file://02_proxy.sh"

do_configure() {
    bbplain "Configuring proxy setup script."

    cp "${WORKDIR}"/02_proxy.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/

    # Replace proxy environment variable placeholders
    # Can be done early as proxy is already known at this point
    sed -i "s|@EC_PROXY_SERVER@|$EC_PROXY_SERVER|g" "${EC_TARGET_INSTALL_DIR}/etc/profile.d/02_proxy.sh"
    sed -i "s|@EC_PROXY_PORT@|$EC_PROXY_PORT|g" "${EC_TARGET_INSTALL_DIR}/etc/profile.d/02_proxy.sh"
    sed -i "s|@EC_PROXY_USER@|$EC_PROXY_USER|g" "${EC_TARGET_INSTALL_DIR}/etc/profile.d/02_proxy.sh"
    sed -i "s|@EC_PROXY_PASSWORD@|$EC_PROXY_PASSWORD|g" "${EC_TARGET_INSTALL_DIR}/etc/profile.d/02_proxy.sh"
    sed -i "s|@EC_NO_PROXY@|$EC_NO_PROXY|g" "${EC_TARGET_INSTALL_DIR}/etc/profile.d/02_proxy.sh"
}
