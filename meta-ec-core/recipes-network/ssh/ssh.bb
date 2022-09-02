DESCRIPTION = ""
PN = "ssh"
PV = "1"

inherit installable

do_configure() {
    bbplain "Adding empty SSH client configuration file."
    mkdir -p ~/.ssh/
    touch ~/.ssh/config
}
