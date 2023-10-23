def get_pip_trusted_hosts(d):
    if not bb.utils.to_boolean(d.getVar("BB_CHECK_SSL_CERTS")):
        return "--trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org"
    else:
        return ""

PIP_TRUSTED_HOSTS = "${@get_pip_trusted_hosts(d)}"
