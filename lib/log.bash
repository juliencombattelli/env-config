source ansi.bash

function _ec_time {
    printf "%(%Y-%m-%d %H:%M:%S)T" -1
}

function ec_log_plain {
    printf "%s\n" "$@" >&2
}

function ec_log_debug {
    printf "$(_ec_time) $(ansi_style fg=cyan)D$(ansi_style) %s\n" "$@" >&2
}

function ec_log_note {
    printf "$(_ec_time) $(ansi_style bold fg=white)N$(ansi_style) %s\n" "$@" >&2
}

function ec_log_warn {
    printf "$(_ec_time) $(ansi_style bold fg=yellow)W$(ansi_style) $(ansi_style bold fg=yellow)%s$(ansi_style)\n" "$@" >&2
}

function ec_log_error {
    printf "$(_ec_time) $(ansi_style bold fg=red)E$(ansi_style) $(ansi_style bold fg=red)%s$(ansi_style)\n" "$@" >&2
}
