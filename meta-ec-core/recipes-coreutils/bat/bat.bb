DESCRIPTION = ""
PN = "bat"
PV = "1"

inherit installable

SRC_URI += " file://bat-manpager.sh "

python() {
    d.setVar("BAT_COMMAND", "bat")
    aliases = d.getVarFlags("ALIAS")
    for alias,command in aliases.items():
        if alias == "bat":
            d.setVar("BAT_COMMAND", command.split()[0])
            return
}

do_configure() {
    install "${WORKDIR}"/bat-manpager.sh "${EC_TARGET_INSTALL_DIR}"/etc/profile.d/
}
