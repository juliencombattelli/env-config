DESCRIPTION = ""
PN = "apt"
PV = "1"

inherit pkg_provider

do_update() {
    bbplain "Updating pkg-provider ${PN}"
    sudo apt update
}

do_install_packages() {
    bbplain "Installing packages using pkg-provider ${PN}"
    # sudo apt install -y toto
}