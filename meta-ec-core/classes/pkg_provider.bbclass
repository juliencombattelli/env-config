# Base class for all pkg_providers

# TODO rework
# Remove this class and create pkg_providers recipe from this class
python pkg_provider_do_update() {
    bb.plain(f"Updating pkg-provider {d.getVar('PN')}")
}
addtask do_update

EXPORT_FUNCTIONS do_update

do_install[noexec] = "1"
do_configure[noexec] = "1"