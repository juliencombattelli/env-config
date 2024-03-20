DESCRIPTION = ""
PN = "wsl"
PV = "1"

SRC_URI += "file://wsl.conf"

do_install[noexec] = "1"

do_configure() {
    sed -i "s/<placeholder>/$USER/" ${WORKDIR}/wsl.conf
    if [ -f /etc/wsl.conf ]; then
        if [ "$FORCE_WSL_CONF" = "1" ]; then
            bbplain "Deploying WSL distro config file (forced)."
            sudo install ${WORKDIR}/wsl.conf /etc/wsl.conf
        else
            bbplain "WSL distro config file already deployed, nothing to do."
        fi
    else
        bbplain "Deploying WSL distro config file."
        sudo install ${WORKDIR}/wsl.conf /etc/wsl.conf
    fi
}
