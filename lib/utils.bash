function ec_contains {
    local pattern="$1"
    shift
    for i in "$@"; do
        if [[ "$i" == "$pattern" ]]; then
            return 0
        fi
    done
    return 1
}
