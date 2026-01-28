DESCRIPTION = ""
PN = "zig"
ZIG_VER = "0.15.2"
PV = "${ZIG_VER}"

SRC_URI += " \
    file://zig.sh \
    https://ziglang.org/download/${ZIG_VER}/zig-x86_64-linux-${ZIG_VER}.tar.xz;name=zig.tar.xz \
"
SRC_URI[zig.tar.xz.sha256sum] = "02aa270f183da276e5b5920b1dac44a63f1a49e55050ebde3aecc9eb82f93239"

do_install() {
    bbplain "Installing zig."

    cp "${WORKDIR}/zig.sh" "${EC_INSTALL_DIR}"

    mkdir -p "${EC_DATA_DIR}/zig"
    # Remove previous installation if any
    rm -rf "${EC_DATA_DIR}/zig/zig"
    cp -r "${WORKDIR}/zig-x86_64-linux-${ZIG_VER}" "${EC_DATA_DIR}/zig/zig"

    # TODO add zls
}
