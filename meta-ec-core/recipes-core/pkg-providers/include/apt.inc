def pkg_provider_apt_search_package(d, pattern, version):
    # TODO rework: using python-apt
    # Get the package with the more recent "version" number (eg. clang-10 more recent than clang-6.0)
    # The grep is needed since apt may return alternatives not matching the pattern (eg. vim, vim-gtk, vim-nox)
    get_pkg_name = f"apt-cache search -n -qq '^{pattern}$' | cut -d' ' -f1 | grep -E '^{pattern}$' | sort -rV | head -n1"
    pkg_name = run_shell_cmd(d, get_pkg_name)

def pkg_provider_apt_update(d):
    pass
    
def pkg_provider_apt_install_packages(d):
    pass