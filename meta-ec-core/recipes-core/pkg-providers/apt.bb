inherit pkg_provider

python do_update() {
    bb.plain("Updating apt cache")
    # sudo apt update
}