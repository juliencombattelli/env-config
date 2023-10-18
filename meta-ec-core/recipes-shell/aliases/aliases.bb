DESCRIPTION = ""
PN = "aliases"
PV = "1"

python do_configure() {
    bb.plain("Configuring shell aliases.")
    # Add an alias entry in the aliases script file for each ALIAS defined in config
    aliases = d.getVarFlags("ALIAS")
    aliasfile = d.getVar("EC_TARGET_INSTALL_DIR") + "/etc/profile.d/aliases.sh"
    with open(aliasfile, "w", encoding="utf-8") as f:
        for alias,command in aliases.items():
            f.write('alias {}="{}"\n'.format(alias, command))
}
