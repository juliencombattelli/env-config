
SRC_URI = "https://bootstrap.pypa.io/get-pip.py"
SRC_URI[sha256sum] = "5aefe6ade911d997af080b315ebcb7f882212d070465df544e1175ac2be519b4"

do_install() {
    # TODO check if pip is installed
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
