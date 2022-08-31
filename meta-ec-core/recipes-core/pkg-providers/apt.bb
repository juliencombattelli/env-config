inherit pkg_provider

python do_fetch_source_list() {
    src_uri = (d.getVar("SRC_URI") or "").split()
    fetcher = bb.fetch2.Fetch(src_uri, d)
    try:
        fetcher.download()
    except bb.fetch2.FetchError as e:
        bb.verbnote("""

############################## READ THE FOLLOWING NOTE #################################
# Please check tmp/work/apt-1.0-r0/temp/log.do_fetch_source_list.                      #
# If the logs mention the following error message:                                     #
#     ERROR: cannot verify <domain>'s certificate, issued by ‘<certificate-issuer>’:   #
#     Self-signed certificate encountered.                                             #
# this means your certifiate issuer is not trusted.                                    #
# If <certificate-issuer> is a trusted organisation (ie. your corporate organisation), #
# then proceed by either adding it to your known and trusted certificate store,        #
# or by adding BB_CHECK_SSL_CERTS = "0" to your conf/local.conf file.                  #
#################################### END OF NOTE #######################################
""")
        bb.fatal("Exiting.")
    rootdir = d.getVar("WORKDIR")
    fetcher.unpack(rootdir)
}
addtask do_fetch_source_list before do_update_source_list

do_update_source_list() {
    bbplain "Updating apt source lists (stubbed)."
    bbplain ${WORKDIR}/*.list
    # sudo cp ${WORKDIR}/*.list /etc/apt/sources.list.d/
    bbplain "Adding archive keys (stubbed)."
    bbplain ${WORKDIR}/*.key
    # sudo apt-key add ${WORKDIR}/*.key
}
addtask do_update_source_list before do_update

do_update() {
    bbplain "Updating apt cache."
    sudo -E apt update
}
addtask do_update
