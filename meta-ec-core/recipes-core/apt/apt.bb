inherit apt-base

do_apt_install_script_start() {
    mkdir -p $(dirname ${APT_INSTALL_SCRIPT_LOCATION})
    echo "#!/bin/bash" > "${APT_INSTALL_SCRIPT_LOCATION}"
    echo "sudo apt update" >> "${APT_INSTALL_SCRIPT_LOCATION}"
    echo "sudo apt install \\" >> "${APT_INSTALL_SCRIPT_LOCATION}"
}
addtask do_apt_install_script_start
do_apt_install_script_start[lockfiles] = "${APT_INSTALL_SCRIPT_LOCKFILE}"
do_apt_install_script_start[nostamp] = "1"
