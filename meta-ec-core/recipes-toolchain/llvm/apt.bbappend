FILESPATH:prepend := "${THISDIR}/${PN}:"

BB_STRICT_CHECKSUM = "0"

SRC_URI:append = " \
    https://apt.llvm.org/llvm.sh \
"

do_update:append() {
    chmod +x ${WORKDIR}/llvm.sh
    # Install current stable version
    sudo ${WORKDIR}/llvm.sh
}
