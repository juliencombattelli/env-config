DESCRIPTION = ""
PN = "git"
PV = "1"

inherit installable

do_configure() {
    bbplain "Configuring git."
    git config --global user.email "julien.combattelli@gmail.com"
    git config --global user.name "Julien Combattelli"
    git config --global color.ui "always"
}
