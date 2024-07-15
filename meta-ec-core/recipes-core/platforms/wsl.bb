DESCRIPTION = ""
PN = "wsl"
PV = "1"

SRC_URI += " file://etc/wsl.conf \
    file://bin/clip \
    file://bin/code \
    file://bin/explorer \
    file://bin/powershell \
    file://bin/wsl \
"

do_install[noexec] = "1"

do_configure() {
    bbplain "Installing WSL interoperability wrappers."
    for wrapper in ${WORKDIR}/bin/*; do
        sudo install ${wrapper} /usr/local/bin
        # Create a symlink for the .exe variant
        sudo ln -sf $(basename ${wrapper}) /usr/local/bin/$(basename ${wrapper}).exe
    done

    sed -i "s/<placeholder>/$USER/" ${WORKDIR}/etc/wsl.conf
    DEPLOY_CONFIG=
    if [ -f /etc/wsl.conf ]; then
        if [ "$FORCE_WSL_CONF" = "1" ]; then
            bbplain "Deploying WSL distro config file (forced)."
            DEPLOY_CONFIG=1
        elif ! grep ">>> env-config <<<" /etc/wsl.conf &>/dev/null; then
            bbplain "Deploying WSL distro config file (backing up original one)."
            sudo mv /etc/wsl.conf /etc/wsl.conf.bak-by-env-config
            DEPLOY_CONFIG=1
        else
            bbplain "WSL distro config file already deployed, nothing to do."
        fi
    else
        bbplain "Deploying WSL distro config file."
        DEPLOY_CONFIG=1

    fi
    if [ -n "$DEPLOY_CONFIG" ]; then
        sudo install -m 644 ${WORKDIR}/etc/wsl.conf /etc/wsl.conf
    fi
}
