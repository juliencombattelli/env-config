DESCRIPTION = ""
PN = "aliases"
PV = "1"

SRC_URI += "file://aliases.sh"

copy_base_file() {
    cp "${WORKDIR}"/aliases.sh "${EC_INSTALL_DIR}"
}

python do_configure() {
    bb.plain("Configuring shell aliases.")
    bb.build.exec_func("copy_base_file", d)
    # Add an alias entry in the aliases script file for each ALIAS defined in config
    aliases = d.getVarFlags("ALIAS")
    aliasfile = d.getVar("EC_INSTALL_DIR") + "/aliases.sh"
    with open(aliasfile, "a", encoding="utf-8") as f:
        for alias,command in aliases.items():
            f.write('define_alias {} {}\n'.format(alias, command))
}
