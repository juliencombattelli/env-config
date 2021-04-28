inherit apt-base

APT_PACKAGE_NAME ?= "${PN}"

do_apt_install_script() {
    echo "    ${APT_PACKAGE_NAME} \\" >> "${APT_INSTALL_SCRIPT_LOCATION}"
}
addtask do_apt_install_script
do_apt_install_script[lockfiles] = "${APT_INSTALL_SCRIPT_LOCKFILE}"
do_apt_install_script[depends] = "apt:do_apt_install_script_start"
do_apt_install_script[nostamp] = "1"

addtask do_generate_apt_install_script after do_apt_install_script
do_generate_apt_install_script[recrdeptask] = "do_generate_apt_install_script do_apt_install_script"
do_generate_apt_install_script() {
    :
}


EXPORT_FUNCTIONS do_apt_install_script
