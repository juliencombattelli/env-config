DESCRIPTION = "Prints Hello World"
PN = 'bash'
PV = '1'

python do_build() {
    bb.plain("Building bash!")
}
