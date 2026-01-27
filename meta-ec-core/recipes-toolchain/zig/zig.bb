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

    cp "${WORKDIR}/zig.sh" "${EC_TARGET_INSTALL_DIR}/etc/profile.d/"

    mkdir -p "$HOME/.local/share/zig"
    # Remove previous installation if any
    rm -rf "$HOME/.local/share/zig/zig"
    cp -r "${WORKDIR}/zig-x86_64-linux-${ZIG_VER}" "$HOME/.local/share/zig/zig"

    # TODO add zls
}
