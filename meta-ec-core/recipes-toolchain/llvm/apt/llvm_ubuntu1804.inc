do_update:append() {
    # Ubuntu 18.04 LLVM PPA requires Ubuntu's testing toolchain PPA
    sudo -E add-apt-repository 'ppa:ubuntu-toolchain-r/test'
    sudo -E apt update
}
