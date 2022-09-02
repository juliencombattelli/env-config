inherit pkg_provider

# TODO install pip from https://bootstrap.pypa.io/get-pip.py
# Update pip with python3 -m pip install --upgrade pi

python do_update() {
    bb.plain("Updating pip (stubbed).")
}
