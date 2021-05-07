def _apt_vercmp_op(a, b, op):
    import apt
    if op in ('=='):
        return a == b
    elif op == '<=':
        return a <= b
    elif op == '>=':
        return a >= b
    elif op in ('>'):
        return a > b
    elif op in ('<'):
        return a < b
    elif op == '!=':
        return a != b
    else:
        raise Exception('Unsupported comparison operator "{}"'.format(op))

def _apt_vercmp(version, versionspec):
    import apt
    versionspec = versionspec.strip()
    i = 0
    if versionspec.startswith(('<=', '==', '!=', '>=')):
        i = 2
    elif versionspec.startswith(('<', '>')):
        i = 1
    return _apt_vercmp_op(version, versionspec[i:].strip(), versionspec[0:i] or "==")

def main():
    pattern = "^clang-[0-9.]+$"
    version = None

def pkg_provider_apt_search_package_old(d, pattern, version):
    # TODO rework: using python-apt
    # Get the package with the more recent "version" number (eg. clang-10 more recent than clang-6.0)
    # The grep is needed since apt may return alternatives not matching the pattern (eg. vim, vim-gtk, vim-nox)
    get_pkg_name = f"apt-cache search -n -qq '^{pattern}$' | cut -d' ' -f1 | grep -E '^{pattern}$' | sort -rV | head -n1"
    pkg_name = run_shell_cmd(d, get_pkg_name)

def pkg_provider_apt_search_package(d, pattern, version):
    import re
    import apt

    search_pattern = re.compile(pattern)

    class RegexNameFilter(apt.cache.Filter):
        def apply(self, pkg):
            return search_pattern.match(pkg.name)

    def natural_sort_key(s, _nsre=re.compile('([0-9]+)')):
        return [int(text) if text.isdigit() else text.lower() for text in _nsre.split(s)]

    cache = apt.cache.FilteredCache(apt.Cache())
    cache.set_filter(RegexNameFilter())

    for pkg in sorted([pkg.name for pkg in cache], key=natural_sort_key, reverse=True):
        if version is None or _apt_vercmp(cache[pkg].versions[0], version):
            return pkg, cache[pkg].is_installed
    return None, False

def pkg_provider_apt_update(d):
    # update = "sudo apt update"
    # run_shell_cmd(d, update)
    pass
    
def pkg_provider_apt_install_packages(d):
    # Gather all packages from a folder
    # Join them
    # install = "sudo apt install --yes <list of packages>"
    # run_shell_cmd(d, install)
    pass