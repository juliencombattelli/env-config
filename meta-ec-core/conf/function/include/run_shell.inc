def run_shell(d, script):
    """
    Run a shell script located in meta-ec-core/files/
    """
    import subprocess
    cmd = 'sh ' + d.getVar('ECROOT') + '/meta-ec-core/files/' + script
    process = subprocess.run(cmd, shell=True, check=True, encoding='UTF-8', stdout=subprocess.PIPE)
    return process.stdout.strip()