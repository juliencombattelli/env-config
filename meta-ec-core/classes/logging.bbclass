die() {
    bbfatal "$*"
}

bbnote() {
    echo "NOTE:" "$*"
}

bbwarn() {
    echo "WARNING:" "$*"
}

bbfatal() {
    echo "FATAL:" "$*"
    exit 1
}