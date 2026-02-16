source ansi.bash

function ec_log_plain {
    printf "%s\n" "$@" >&2
}

function ec_log_debug {
    printf "[$(ansi_style fg=cyan)DEBUG$(ansi_style)] %s\n" "$@" >&2
}

function ec_log_note {
    printf "[$(ansi_style bold fg=white)NOTE $(ansi_style)] %s\n" "$@" >&2
}

function ec_log_warn {
    printf "[$(ansi_style bold fg=yellow)WARN $(ansi_style)] $(ansi_style bold fg=yellow)%s$(ansi_style)\n" "$@" >&2
}

function ec_log_error {
    printf "[$(ansi_style bold fg=red)ERROR$(ansi_style)] $(ansi_style bold fg=red)%s$(ansi_style)\n" "$@" >&2
}
