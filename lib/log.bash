source ansi.bash

EC_LOG_COLOR=true

function _ec_log_ansi_style {
    if $EC_LOG_COLOR; then
        ansi_style "$@"
    fi
}

function _ec_time {
    printf "%(%Y-%m-%d %H:%M:%S)T" -1
}

function ec_log_plain {
    printf "%s\n" "$@" >&2
}

function ec_log_debug {
    printf "$(_ec_time) $(_ec_log_ansi_style fg=cyan)D$(_ec_log_ansi_style) %s\n" "$@" >&2
}

function ec_log_note {
    printf "$(_ec_time) $(_ec_log_ansi_style bold fg=white)N$(_ec_log_ansi_style) %s\n" "$@" >&2
}

function ec_log_warn {
    printf "$(_ec_time) $(_ec_log_ansi_style bold fg=yellow)W$(_ec_log_ansi_style) $(_ec_log_ansi_style bold fg=yellow)%s$(_ec_log_ansi_style)\n" "$@" >&2
}

function ec_log_error {
    printf "$(_ec_time) $(_ec_log_ansi_style bold fg=red)E$(_ec_log_ansi_style) $(_ec_log_ansi_style bold fg=red)%s$(_ec_log_ansi_style)\n" "$@" >&2
}
