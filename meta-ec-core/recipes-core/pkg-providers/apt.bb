inherit pkg_provider

python do_fetch_source_list() {
    src_uri = (d.getVar('SRC_URI') or "").split()
    fetcher = bb.fetch2.Fetch(src_uri, d)
    fetcher.download()
    rootdir = d.getVar('WORKDIR')
    fetcher.unpack(rootdir)
}
addtask do_fetch_source_list before do_update_source_list

do_update_source_list() {
    bbplain "Updating apt source lists"
    bbplain ${WORKDIR}/*.list
    # sudo cp ${WORKDIR}/*.list /etc/apt/sources.list.d/
    bbplain "Adding archive keys"
    bbplain ${WORKDIR}/*.key
    # sudo apt-key add ${WORKDIR}/*.key
}
addtask do_update_source_list before do_update

do_update() {
    bbplain "Updating apt cache"
    sudo apt update
}
addtask do_update
