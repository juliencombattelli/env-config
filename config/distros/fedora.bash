EC_FEDORA_ATOMIC=false
if cat /proc/mounts | grep " / " | cut -d' ' -f4 | grep -E "(^|,)ro(,|$)" &>/dev/null; then
    EC_FEDORA_ATOMIC=true
fi

EC_DISTRO_PKG_PROVIDERS+=(dnf pip)

EC_PKG_PROVIDER_dnf_PKG_PATTERN[clang-format]='^clang-tools-extra$'
EC_PKG_PROVIDER_dnf_PKG_PATTERN[clang-tidy]='^clang-tools-extra$'
EC_PKG_PROVIDER_dnf_PKG_PATTERN[ninja]='^ninja-build$'
EC_PKG_PROVIDER_dnf_PKG_PATTERN[ssh]='^openssh-clients$'
EC_PKG_PROVIDER_dnf_PKG_PATTERN[wget]='^wget2-wget$'
