# Generic functions not relying on any global state

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

function ec_join {
    local delim=${1-} f=${2-}
    if shift 2; then
        printf %s "$f" "${@/#/$delim}"
    fi
}

function ec_join_affix {
    local delim=${1-} pre=${2-} post=${3-}
    if shift 3; then
        set -- "${@/#/$pre}"
        set -- "${@/%/$post}"
        ec_join "$delim" "$@"
    fi
}
