FILESPATH:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://kitware_${DISTRO}.list;subdir=list \
    https://apt.kitware.com/keys/kitware-archive-latest.asc;name=kitware \
"

do_update_keyring:append() {
    bbplain "Adding Kitware public key."
    cat ${WORKDIR}/kitware-archive-latest.asc | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
}

do_update:append() {
    bbplain "Remove previously installed Kitware public key."
    sudo rm -f /usr/share/keyrings/kitware-archive-keyring.gpg
    bbplain "Installing Kitware Archive Keyring package."
    sudo -E apt-get install kitware-archive-keyring
}
