# Return the currently installed version of the given package, or None if it is not installed
def _pip_is_pkg_installed(d, pkg):
    import json
    import sys
    list_command = "{python} -m pip list --format=json".format(python=sys.executable)
    list = run_shell_cmd(d, list_command)
    if list.returncode == 0:
        versions = [p['version'] for p in json.loads(list.stdout) if p['name'] == pkg]
        if len(versions) == 0:
            return None # Package not installed
        if len(versions) > 1:
            bb.error("Multiple versions found for package `{}` {}, this use case is not supported".format(pkg, versions))
        return versions[0]
    return None

# Return the available version of the given package, or None if it is not available
def _pip_is_pkg_available(d, pkg, version_spec):
    import re
    import sys
    from distutils.version import LooseVersion
    index_command = "{python} -m pip index versions {pkg}".format(python=sys.executable, pkg=pkg)
    index = run_shell_cmd(d, index_command)
    if index.returncode == 0:
        for line in index.stdout.splitlines():
            # Extract versions from index; to be updated if pip devs add a --format=json option
            match = re.search("^Available versions: (.*)$", line)
            if match:
                versions = match.group(1).split(", ")
                versions.sort(key=LooseVersion, reverse=True)
                if len(versions) == 0:
                    return False, None # Package not found
                if version_spec: # If version_spec is provided, look for this specific version
                    op, vb = re.split("([=<>!]+)(.*)", version_spec)[1:3]
                    for va in versions:
                        if bb.utils.vercmp_string_op(va, vb, op):
                            return True, vb # Package found at the specified version
                    return False, None # Package not found at the specified version
                return True, None # Package found, no version required
    return False, None # Package not found

def pkg_provider_pip_search_package(d, pkg, _, version):
    installed_version = _pip_is_pkg_installed(d, pkg)
    # TODO do version check of installed version
    is_installed = installed_version is not None
    if not is_installed:
        # Get available version in the PyPi index
        is_pkg_found, version = _pip_is_pkg_available(d, pkg, version)
        pkg = pkg if is_pkg_found else None
    return pkg, version, is_installed

def pkg_provider_pip_install_packages(d, pkg, version):
    import sys
    version_spec = version or ""
    install_command = "{python} -m pip install {pkg}{version}".format(
        python=sys.executable, pkg=pkg, version=version_spec)
    install = run_shell_cmd(d, install_command)
    if install.returncode != 0:
        bb.error("Unable to install package {} using pip".format(pkg))
