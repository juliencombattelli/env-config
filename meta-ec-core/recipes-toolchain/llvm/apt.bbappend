FILESPATH_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " file://llvm_${DISTRO}.list https://apt.llvm.org/llvm-snapshot.gpg.key"
SRC_URI[sha256sum] = "ce6eee4130298f79b0e0f09a89f93c1bc711cd68e7e3182d37c8e96c5227e2f0"
