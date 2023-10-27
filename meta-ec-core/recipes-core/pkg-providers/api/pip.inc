require recipes-core/pkg-providers/include/pip-common.inc

def pkg_provider_pip_search_package(d, pkg, _):
    # Currently installed package version
    installed = ""
    # All available version in index
    versions = []
    # List of packages with their version and whether they are installed
    packages = []
    # Get index information for the given package
    index_command = "{python} -m pip {trusted_hosts} index versions {pkg}".format(
        python=sys.executable, trusted_hosts=d.getVar("PIP_TRUSTED_HOSTS"), pkg=pkg)
    index = run_shell_cmd(d, index_command)
    if index.returncode == 0:
        for line in index.stdout.splitlines():
            # Extract versions from index; to be updated if pip devs add a --format=json option
            match = re.search("^Available versions: (.*)$", line)
            if match:
                versions = match.group(1).split(", ")
            match = re.search("^  INSTALLED: (.*)$", line)
            if match:
                installed = match.group(1)
        packages = [(pkg, version, version == installed) for version in versions]
    return packages

def pkg_provider_pip_install_packages(d, pkg, version):
    version_spec = version or ""
    install_command = "{python} -m pip {trusted_hosts} install {pkg}=={version}".format(
        python=sys.executable, trusted_hosts=d.getVar("PIP_TRUSTED_HOSTS"), pkg=pkg, version=version_spec)
    install = run_shell_cmd(d, install_command)
    if install.returncode != 0:
        bb.error("Unable to install package {} using pip".format(pkg))
