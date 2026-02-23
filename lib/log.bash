source ansi.bash

EC_LOG_COLOR=true
EC_LOG_DIR=

function _ec_log_ansi_style {
    if $EC_LOG_COLOR; then
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
    local level="$1"
    shift
    printf "$(_ec_time)$(_ec_log_level_"$level") %s\n" "$@" >&2
    if [[ -d "$EC_LOG_DIR" ]]; then
        printf "$(_ec_time) $level %s\n" "$@" >> "$EC_LOG_DIR/env-config.log"
    fi
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
