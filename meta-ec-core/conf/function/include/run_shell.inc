def run_shell_cmd(d, cmd):
    """
    Run a shell command
    """
    import subprocess
    return subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, encoding='utf-8')

def run_shell_script(d, script):
    """
    Run a shell script located in meta-ec-core/scripts/
    """
    cmd = 'sh ' + d.getVar('ECROOT') + '/meta-ec-core/scripts/' + script
    return run_shell_cmd(d, cmd)
