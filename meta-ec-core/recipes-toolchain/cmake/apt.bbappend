FILESPATH:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://kitware_${DISTRO}.list;subdir=list \
    https://apt.kitware.com/keys/kitware-archive-latest.asc;name=kitware \
"
SRC_URI[kitware.sha256sum] = "e5623682be770120158e5b28282c7862736f4a42db833661db65bfa211037512"

do_update_keyring:append() {
    bbplain "Adding kitware public key"
    cat ${WORKDIR}/kitware-archive-latest.asc | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
}

do_update:append() {
    sudo -E apt-get install kitware-archive-keyring
}