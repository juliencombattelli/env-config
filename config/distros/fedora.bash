if [[ -n ${EC_FEDORA_ATOMIC:-} ]] || cat /proc/mounts | grep " / " | cut -d' ' -f4 | grep -E "(^|,)ro(,|$)" &>/dev/null; then

    EC_FEDORA_ATOMIC=true
    EC_DISTRO_PKG_PROVIDERS+=(homebrew)

    mkdir -p "$EC_DOWNLOADS_DIR/homebrew"
    wget --directory-prefix="$EC_DOWNLOADS_DIR/homebrew" --no-verbose --timestamping \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
    NONINTERACTIVE=1 bash "$EC_DOWNLOADS_DIR/homebrew/install.sh"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"

    EC_PKG_PROVIDER_homebrew_PKG_PATTERN[clang]='^llvm$'
    EC_PKG_PROVIDER_homebrew_PKG_PATTERN[clang-format]='^llvm$'
    EC_PKG_PROVIDER_homebrew_PKG_PATTERN[clang-tidy]='^llvm$'
    EC_PKG_PROVIDER_homebrew_PKG_PATTERN[ccmake]='^cmake$'
    EC_PKG_PROVIDER_homebrew_PKG_PATTERN[ssh]='^openssh$'

else

    EC_FEDORA_ATOMIC=false
    EC_DISTRO_PKG_PROVIDERS+=(dnf)

    EC_PKG_PROVIDER_dnf_PKG_PATTERN[clang-format]='^clang-tools-extra$'
    EC_PKG_PROVIDER_dnf_PKG_PATTERN[clang-tidy]='^clang-tools-extra$'
    EC_PKG_PROVIDER_dnf_PKG_PATTERN[ninja]='^ninja-build$'
    EC_PKG_PROVIDER_dnf_PKG_PATTERN[ssh]='^openssh-clients$'
    EC_PKG_PROVIDER_dnf_PKG_PATTERN[wget]='^wget2-wget$'

fi
