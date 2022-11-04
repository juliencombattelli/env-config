BB_STRICT_CHECKSUM = "0"
SRC_URI = "https://bootstrap.pypa.io/get-pip.py"

do_install() {
    bbplain "Installing pip."
    if !python3 -m pip --version; then
        python3 ${WORKDIR}/get-pip.py
    else
        bbplain "pip already installed."
    fi

    bbplain "Installing pypisearch."
    python3 -m pip install pypisearch
}
addtask do_install before do_update

do_update() {
    bbplain "Updating pip."
    python3 -m pip install --upgrade pip
}
addtask do_update

do_configure[noexec] = "1"
