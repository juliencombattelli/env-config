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

def pkg_provider_apt_install_packages(d, pkg):
    install = "sudo -E apt install --yes {}".format(pkg)
    run_shell_cmd(d, install)
