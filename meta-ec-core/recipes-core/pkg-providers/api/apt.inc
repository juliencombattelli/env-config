def pkg_provider_apt_search_package(d, pattern, wholeword):
    try:
        import apt
    except ModuleNotFoundError:
        bb.warn("Python APT's library not found, skipping.")
        return []

    if wholeword:
        pattern = "^{}$".format(pattern)

    search_pattern = re.compile(pattern)

    # According to https://www.debian.org/doc/debian-policy/ch-controlfields.html#version,
    # version field format of debian packages is [epoch:]upstream_version[-debian_revision]
    # The upstream_version is extracted in group 2 (only major.minor.patch is extracted)
    # TODO emit warning if package does not follow semver using bb.utils.is_semver()
    deb_pkg_version_re = re.compile(r'^(\d+:)?(\d+(\.\d+){0,2})')

    class RegexNameFilter(apt.cache.Filter):
        def apply(self, pkg):
            return search_pattern.match(pkg.name)

    def natural_sort_key(s, _nsre=re.compile('([0-9]+)')):
        return [int(text) if text.isdigit() else text.lower() for text in _nsre.split(s)]

    cache = apt.cache.FilteredCache(apt.Cache())
    cache.set_filter(RegexNameFilter())

    packages = []
    for pkg in sorted([pkg.name for pkg in cache], key=natural_sort_key, reverse=True):
        # Consider only the first version in the list
        # TODO check if it is always the more recent
        pkg_version = deb_pkg_version_re.match(cache[pkg].versions[0].version).group(2)
        packages.append((pkg, pkg_version, cache[pkg].is_installed))
    return packages

def pkg_provider_apt_install_packages(d, pkg, _):
    # Version argument is not used with apt for now
    install = "sudo -E apt install --yes {}".format(pkg)
    run_shell_cmd(d, install)
