DESCRIPTION = ""
PN = "bash"
PV = "1"

inherit installable

FILESPATH:prepend := "${THISDIR}/files:"

SRC_URI = "file://.bashrc"

do_configure() {
    bbplain "Configuring bash."

    bbplain "Updating bashrc."
    cp /etc/skel/.bashrc ~/.bashrc
    sed "s|@EC_TARGET_INSTALL_DIR@|${EC_TARGET_INSTALL_DIR}|g" ${WORKDIR}/.bashrc >> ~/.bashrc
}
