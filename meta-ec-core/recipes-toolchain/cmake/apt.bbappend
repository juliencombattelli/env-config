FILESPATH:prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://kitware_${DISTRO}.list;subdir=list"

do_update_keyring:append() {
    # Only update Kitware key if kitware-archive-keyring is not installed
    if [ ! -f /usr/share/doc/kitware-archive-keyring/copyright ]; then
        bbplain "Adding Kitware public key."
        # Download without using SRC_URI to avoid checksum verification issues
        wget https://apt.kitware.com/keys/kitware-archive-latest.asc --output-document ${WORKDIR}/kitware-archive-latest.asc
        cat ${WORKDIR}/kitware-archive-latest.asc | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
    fi
}

do_update:append() {
    # If kitware-archive-keyring is not installed, remove any key present and install it
    if [ ! -f /usr/share/doc/kitware-archive-keyring/copyright ]; then
        bbplain "Remove previously installed Kitware public key."
        sudo rm -f /usr/share/keyrings/kitware-archive-keyring.gpg
        bbplain "Installing Kitware Archive Keyring package."
        sudo -E apt-get install kitware-archive-keyring
    fi
}
