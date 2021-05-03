# Add here a search function and a register_for_installation

def apt_search_package(d, pattern):
    # Get the package with the more recent "version" number (eg. clang-10 more recent than clang-6.0)
    cmd = f"apt-cache search --names-only -qq '{pattern}' | cut -d' ' -f1 | sort -rV | head -n1"
    return run_shell_cmd(d, cmd)
