def pkg_provider_pip_search_package(d, pattern, version):
    # TODO install pypisearch
    # search a pkg with:
    # python3 -m pypisearch "cmake" | grep -oh "^[a-zA-Z0-9._-]\+ ([0-9]\+\.[0-9a-zA-Z.]\+)"
    return None, False

def pkg_provider_pip_update(d):
    pass

def pkg_provider_pip_install_packages(d):
    pass