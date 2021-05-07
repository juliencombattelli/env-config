inherit pkg_provider

python do_update() {
    bb.plain("Updating pip")
    # python3 -m pip install --upgrade pip
}