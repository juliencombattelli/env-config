FILESPATH:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://llvm_${DISTRO}.list;subdir=list \
    https://apt.llvm.org/llvm-snapshot.gpg.key;name=llvm;subdir=key \
"
SRC_URI[llvm.sha256sum] = "ce6eee4130298f79b0e0f09a89f93c1bc711cd68e7e3182d37c8e96c5227e2f0"
