source ansi.bash

EC_LOG_COLOR_DEFAULT=true
EC_LOG_FILE_DEFAULT=env-config.log

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

function _ec_log_set_output {
    ec_log_color=${EC_LOG_COLOR:-$EC_LOG_COLOR_DEFAULT}
    case "$1" in
        stdout) exec {LOG_FD}>&1;;
        stderr) exec {LOG_FD}>&2;;
        file)   exec {LOG_FD}>>"${EC_LOG_FILE:-$EC_LOG_FILE_DEFAULT}"; ec_log_color=false;;
        *)      exec {LOG_FD}>>"$1"; ec_log_color=false;;
    esac
}

function _ec_log_close_output {
    exec {LOG_FD}>&-
}

function _ec_log {
    local spec="$1"
    shift

    local level targets_spec targets
    IFS='@' read -r level targets_spec <<< "$spec"
    IFS=',' read -ra targets <<< "$targets_spec"

    local default_targets=(file stdout)
    for target in "${targets[@]:-${default_targets[@]}}"; do
        _ec_log_set_output "$target"
        printf "$(_ec_time)$(_ec_log_level_"$level") %s\n" "$@" >&"$LOG_FD"
        _ec_log_close_output
    done
}
