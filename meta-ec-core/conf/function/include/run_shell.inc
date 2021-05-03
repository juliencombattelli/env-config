def run_shell_cmd(d, cmd):
    """
    Run a shell command
    """
    import subprocess
    process = subprocess.run(cmd, shell=True, check=True, encoding='UTF-8', stdout=subprocess.PIPE)
    return process.stdout.strip()

def run_shell_script(d, script):
    """
    Run a shell script located in meta-ec-core/files/
    """
    cmd = 'sh ' + d.getVar('ECROOT') + '/meta-ec-core/files/' + script
    return run_shell_cmd(d, cmd)
