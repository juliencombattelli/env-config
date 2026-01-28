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

install_bat_manpager() {
    install -m 644 "${WORKDIR}/bat-manpager.sh" "${EC_INSTALL_DIR}"
}

python do_configure() {
    bb.plain("Configuring Bat.")
    if d.getVarFlag("PAGER", "man") == "bat":
        bb.build.exec_func("install_bat_manpager", d)
}
