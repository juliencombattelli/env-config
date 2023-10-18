def force_disable_sudo_if_required(d):
    '''
    Run some tests to check if sudo is available and if the current user is
    allowed to use it.
    Return None if disabling sudo is not necessary (meaning sudo is not usable),
    otherwise return a string with the reason why it must be disabled.
    '''
    force_disable_sudo = False
    reason = "unknown"

    # Check if sudo is installed
    if run_shell_cmd(d, "which sudo").returncode is not 0:
        force_disable_sudo = True
        reason = "sudo not installed"
    # Check if running in GCP with sudo disabled
    elif bb.utils.to_boolean(d.getVar("CLOUD_WORKSTATIONS_CONFIG_DISABLE_SUDO")):
        force_disable_sudo = True
        reason = "sudo disabled by GCP"
    # Check if sudo is executable without error
    elif run_shell_cmd(d, "sudo ls").returncode is not 0:
        force_disable_sudo = True
        reason = "sudo not executable"

    # Force disable sudo if any check above indicates that sudo is not available
    if force_disable_sudo:
        return reason
    else:
        return ""
