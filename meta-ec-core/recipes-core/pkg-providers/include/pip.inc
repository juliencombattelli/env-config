def pkg_provider_pip_search_package(d, pattern, version):
    from pypisearch.search import Search
    import re
    search = Search(query=pattern)
    for result in search.result:
        match = re.match(pattern, result.name)
        if match:
            return match.group(0), result.is_installed
    return None, False

def pkg_provider_pip_install_packages(d, pkg):
    import sys
    install = "{python} -m pip install {pkg}".format(python=sys.executable, pkg=pkg)
    run_shell_cmd(d, install)
