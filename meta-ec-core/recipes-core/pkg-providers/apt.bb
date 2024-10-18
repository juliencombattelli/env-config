# apt is always installed in Ubuntu-based distros
do_install[noexec] = "1"

python do_fetch_source_list() {
    src_uri = (d.getVar("SRC_URI") or "").split()
    fetcher = bb.fetch2.Fetch(src_uri, d)
    try:
        fetcher.download()
    except bb.fetch2.FetchError as e:
        bb.verbnote("""

############################## READ THE FOLLOWING NOTE #################################
# Please check tmp/work/apt-1.0-r0/temp/log.do_fetch_source_list.                      #
# If the logs mention the following error message:                                     #
#     ERROR: cannot verify <domain>'s certificate, issued by ‘<certificate-issuer>’:   #
#     Self-signed certificate encountered.                                             #
# this means your certifiate issuer is not trusted.                                    #
# If <certificate-issuer> is a trusted organisation (ie. your corporate organisation), #
# then proceed by either adding it to your known and trusted certificate store,        #
# or by adding BB_CHECK_SSL_CERTS = "0" to your conf/local.conf file.                  #
#################################### END OF NOTE #######################################
""")
        bb.fatal("Exiting.")
    rootdir = d.getVar("WORKDIR")
    fetcher.unpack(rootdir)
}

python do_fetch() {
    bb.build.exec_func("do_fetch_source_list", d)
}

do_update_source_list() {
    if [ "${DISABLE_PKG_PROVIDERS_UPDATE}" = "1" ]; then
        return
    fi
    if [ -d ${WORKDIR}/list ] && [ -n "$(ls -A ${WORKDIR}/list)" ]; then
        bbplain "Updating apt source lists."
        sudo cp ${WORKDIR}/list/* /etc/apt/sources.list.d/
    fi
}
addtask do_update_source_list after do_fetch before do_update_keyring

do_update_keyring() {
    if [ "${DISABLE_PKG_PROVIDERS_UPDATE}" = "1" ]; then
        bbwarn "Package providers updates disabled, skipping Apt keyring updates."
        return
    fi
    if sudo_disabled; then
        bbwarn "Sudo disabled, skipping Apt keyring updates."
        return
    fi
    if [ -d ${WORKDIR}/key ] && [ -n "$(ls -A ${WORKDIR}/key)" ]; then
        bbplain "Adding public keys into apt."
        sudo apt-key add ${WORKDIR}/key/*
    fi
}
addtask do_update_keyring before do_update

do_update() {
    if [ "${DISABLE_PKG_PROVIDERS_UPDATE}" = "1" ]; then
        bbwarn "Package providers updates disabled, skipping Apt updates."
        return
    fi
    if sudo_disabled; then
        bbwarn "Sudo disabled, skipping Apt updates."
        return
    fi
    bbplain "Updating apt cache."
    sudo -E apt update
    sudo -E apt install --yes python3-apt python3-packaging
}
addtask do_update before do_configure

# Always consider do_update as out-of-date
do_update[nostamp] = "1"

do_configure[noexec] = "1"
