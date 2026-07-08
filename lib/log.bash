source ansi.bash

EC_LOG_COLOR=true
EC_LOG_FILE=env-config.log
EC_LOG_TARGETS=($EC_LOG_FILE)

function _ec_log_ansi_style {
    if $ec_log_color; then
        ansi_style "$@"
    fi
}

function _ec_time {
    printf "%(%Y-%m-%d %H:%M:%S)T" -1
}

function _ec_log_level_P {
    :
}

function _ec_log_level_D {
    printf " %sD%s" "$(_ec_log_ansi_style fg=cyan)" "$(_ec_log_ansi_style)"
}

function _ec_log_level_N {
    printf " %sN%s" "$(_ec_log_ansi_style bold fg=white)" "$(_ec_log_ansi_style)"
}

function _ec_log_level_W {
    printf " %sW%s" "$(_ec_log_ansi_style bold fg=yellow)" "$(_ec_log_ansi_style)"
}

function _ec_log_level_E {
    printf " %sE%s" "$(_ec_log_ansi_style bold fg=red)" "$(_ec_log_ansi_style)"
}

function _ec_log {
    function _ec_log_set_output {
        ec_log_color=$EC_LOG_COLOR
        case "$1" in
            stdout) exec {LOG_FD}>&1;;
            stderr) exec {LOG_FD}>&2;;
            *)      exec {LOG_FD}>>"$1"; ec_log_color=false;;
        esac
    }
    function _ec_log_close_output {
        exec {LOG_FD}>&-
    }
    local level="$1"
    shift
    for target in "${EC_LOG_TARGETS[@]}"; do
        _ec_log_set_output "$target"
        printf "$(_ec_time)$(_ec_log_level_"$level") %s\n" "$@" >&"$LOG_FD"
        _ec_log_close_output
    done
}

function ec_log_plain {
    _ec_log P "$@"
}

function ec_log_debug {
    _ec_log D "$@"
}

function ec_log_note {
    _ec_log N "$@"
}

function ec_log_warn {
    _ec_log W "$@"
}

function ec_log_error {
    _ec_log E "$@"
}
