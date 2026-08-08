if [[ -n ${EC_FEDORA_ATOMIC:-} ]] || cat /proc/mounts | grep " / " | cut -d' ' -f4 | grep -E "(^|,)ro(,|$)" &>/dev/null; then
    EC_FEDORA_ATOMIC=true
    EC_DISTRO_PKG_PROVIDERS+=(homebrew)
    EC_PREREQ_PKGS+=(homebrew)
else
    EC_FEDORA_ATOMIC=false
    EC_DISTRO_PKG_PROVIDERS+=(dnf)
fi

EC_PKG_PROVIDER_dnf_PKG_PATTERN[clang-format]='^clang-tools-extra$'
EC_PKG_PROVIDER_dnf_PKG_PATTERN[clang-tidy]='^clang-tools-extra$'
EC_PKG_PROVIDER_dnf_PKG_PATTERN[ninja]='^ninja-build$'
EC_PKG_PROVIDER_dnf_PKG_PATTERN[ssh]='^openssh-clients$'
EC_PKG_PROVIDER_dnf_PKG_PATTERN[wget]='^wget2-wget$'

EC_PKG_PROVIDER_homebrew_PKG_PATTERN[clang]='^llvm$'
EC_PKG_PROVIDER_homebrew_PKG_PATTERN[clang-format]='^llvm$'
EC_PKG_PROVIDER_homebrew_PKG_PATTERN[clang-tidy]='^llvm$'
EC_PKG_PROVIDER_homebrew_PKG_PATTERN[ccmake]='^cmake$'
EC_PKG_PROVIDER_homebrew_PKG_PATTERN[ssh]='^openssh$'
