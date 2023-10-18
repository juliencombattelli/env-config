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

python do_configure() {
    bb.build.exec_func("deploy_base_files", d)
}
