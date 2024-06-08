FILESPATH:prepend := "${THISDIR}/${PN}:"

include apt/llvm_${DISTRO}.inc

do_update:append() {
    # Download without using SRC_URI to avoid checksum verification issues
    wget https://apt.llvm.org/llvm.sh --output-document ${WORKDIR}/llvm.sh
    chmod +x ${WORKDIR}/llvm.sh
    # Install current stable version
    sudo -E ${WORKDIR}/llvm.sh
}
