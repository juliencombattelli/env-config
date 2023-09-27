DESCRIPTION = ""
PN = "base-files"
PV = "1"

FILESPATH := "${THISDIR}:"
SRC_URI = "file://files"

# To add other base files from another layer:
# - put the files to be added in a folder called files-<layer-name>
# - create in this other layer a base-files.bbappend
# - add the following line to your bbappend
#   FILESPATH_append := "${THISDIR}:"
#   SRC_URI += "file://files-<layer-name>"

deploy_base_files() {
    mkdir -p "${EC_TARGET_INSTALL_DIR}"
    # Glob all directory starting with files to include potential appends, see the above note
    # TODO consider replacing all placeholders here
    cp -r "${WORKDIR}"/files*/. "${EC_TARGET_INSTALL_DIR}"
}

replace_proxy_placeholders() {
    # Replace proxy environment variable placeholders
    # Can be done early as proxy is already known at this point
    sed -i "s|@EC_PROXY_SERVER@|$EC_PROXY_SERVER|g" "${EC_TARGET_INSTALL_DIR}/etc/profile.d/proxy.sh"
    sed -i "s|@EC_PROXY_PORT@|$EC_PROXY_PORT|g" "${EC_TARGET_INSTALL_DIR}/etc/profile.d/proxy.sh"
    sed -i "s|@EC_PROXY_USER@|$EC_PROXY_USER|g" "${EC_TARGET_INSTALL_DIR}/etc/profile.d/proxy.sh"
    sed -i "s|@EC_PROXY_PASSWORD@|$EC_PROXY_PASSWORD|g" "${EC_TARGET_INSTALL_DIR}/etc/profile.d/proxy.sh"
    sed -i "s|@EC_NO_PROXY@|$EC_NO_PROXY|g" "${EC_TARGET_INSTALL_DIR}/etc/profile.d/proxy.sh"
}

python create_aliases() {
    aliases = d.getVarFlags("ALIAS")
    aliasfile = d.getVar("EC_TARGET_INSTALL_DIR") + "/etc/profile.d/aliases.sh"
    with open(aliasfile, "w", encoding="utf-8") as f:
        for alias,command in aliases.items():
            f.write('alias {}="{}"\n'.format(alias, command))
}

python do_configure() {
    bb.build.exec_func("deploy_base_files", d)
    bb.build.exec_func("replace_proxy_placeholders", d)
    bb.build.exec_func("create_aliases", d)
}
