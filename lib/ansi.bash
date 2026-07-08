# The ANSI control sequences used here are documented in the following pages:
# - https://www.xfree86.org/current/ctlseqs.html
# - https://vt100.net/docs/vt510-rm/contents.html
# Each function references the corresponding ANSI control function on vt100.net

function ansi_cursor_show {
    # https://vt100.net/docs/vt510-rm/DECTCEM.html
    printf "\e[?25h"
}

function ansi_cursor_hide {
    # https://vt100.net/docs/vt510-rm/DECTCEM.html
    printf "\e[?25l"
}

function ansi_cursor_save {
    # https://vt100.net/docs/vt510-rm/DECSC.html
    printf "\e7"
}

function ansi_cursor_restore {
    # https://vt100.net/docs/vt510-rm/DECRC.html
    printf "\e8"
}

function ansi_cursor_position_get {
    # https://vt100.net/docs/vt510-rm/DSR-CPR.html
    # Save current stty settings, then disable echo and canonical mode
    local old_stty
    old_stty=$(stty -g < /dev/tty)
    stty -echo -icanon min 0 time 1 < /dev/tty
    # Ask the terminal: "where is the cursor?"
    printf '\e[6n' > /dev/tty
    # Read the reply: ESC [ row ; col R
    IFS='[;R' read -r -d 'R' _ "$1" "$2" _ < /dev/tty
    # Restore terminal settings
    stty "$old_stty" < /dev/tty
}

function ansi_cursor_position_set {
    # https://vt100.net/docs/vt510-rm/CUP.html
    local -r line=${1:-}
    local -r column=${2:-}
    printf "\e[%d;%dH" "$line" "$column"
}

function ansi_cursor_up {
    # https://vt100.net/docs/vt510-rm/CUU.html
    local -r lines="${1:-}"
    printf "\e[%dA" "$lines"
}

function ansi_cursor_down {
    # https://vt100.net/docs/vt510-rm/CUD.html
    local -r lines="${1:-}"
    printf "\e[%dB" "$lines"
}

function ansi_scroll_up {
    # https://vt100.net/docs/vt510-rm/SU.html
    local -r lines="${1:-}"
    printf "\e[%dS" "$lines"
}

function ansi_scroll_down {
    # https://vt100.net/docs/vt510-rm/SD.html
    local -r lines="${1:-}"
    printf "\e[%dT" "$lines"
}

function ansi_scroll_region_set {
    # https://vt100.net/docs/vt510-rm/DECSTBM.html
    local -r top="${1:-}"
    local -r bottom="${2:-}"
    printf "\e[%d;%dr" "$top" "$bottom"
}

function ansi_scroll_region_reset {
    # https://vt100.net/docs/vt510-rm/DECSTBM.html
    # TODO remove cursor position backup/restore
    ansi_cursor_save
    ansi_scroll_region_set
    ansi_cursor_restore
}

function ansi_erase_rect {
    # https://vt100.net/docs/vt510-rm/DECERA.html
    local -r top=${1:-}
    local -r left=${2:-}
    local -r bottom=${3:-}
    local -r right=${4:-}
    # shellcheck disable=SC2016 # use single quotes to avoid escaping $
    printf '\e[%d;%d;%d;%d$z' "$top" "$left" "$bottom" "$right"
}

function ansi_erase_display_from_cursor_to_bottom {
    # https://vt100.net/docs/vt510-rm/ED.html
    printf "\e[0J"
}

function ansi_erase_display_from_top_to_cursor {
    # https://vt100.net/docs/vt510-rm/ED.html
    printf "\e[1J"
}

function ansi_erase_display {
    # https://vt100.net/docs/vt510-rm/ED.html
    printf "\e[2J"
}

function ansi_erase_line_from_cursor_to_right {
    # https://vt100.net/docs/vt510-rm/EL.html
    printf "\e[0K"
}

function ansi_erase_line_from_cursor_to_left {
    # https://vt100.net/docs/vt510-rm/EL.html
    printf "\e[1K"
}

function ansi_erase_line {
    # https://vt100.net/docs/vt510-rm/EL.html
    printf "\e[2K"
}

function ansi_style {
    # https://vt100.net/docs/vt510-rm/SGR.html
    declare -rA known_colors=(
        [black]=0       [red]=1     [green]=2   [yellow]=3      [blue]=4
        [magenta]=5     [cyan]=6    [white]=7   [default]=9
    )
    declare -rA known_styles=(
        [default]=0
        [bold]=1    [faint]=2       [italic]=3      [underlined]=4      [blink]=5       [inverse]=7     [hidden]=8
        [nobold]=21 [nofaint]=22    [noitalic]=23   [nounderlined]=24   [noblink]=25    [noinverse]=27  [nohidden]=28
    )
    function help {
        IFS=" "
        local -r colors=$(printf "%s\n" "${!known_colors[*]}")
        local -r styles=$(printf "%s\n" "${!known_styles[*]}")
        cat << EOH
Usage:
    ansi_style [fg=<color>] [bg=<color>] [<styles>...]

Colors:
    $colors

Styles:
    $styles
EOH
    }
    declare -a attributes=()
    local color
    while (( $# > 0 )); do
        case $1 in
            -h|--help|help)
                help; return;;
            fg=*)
                color=${1#fg=}
                if [[ -v known_colors[$color] ]]; then
                    attributes+=( $((known_colors[$color] + 30)) )
                fi
                shift;;
            bg=*)
                color=${1#bg=}
                if [[ -v known_colors[$color] ]]; then
                    attributes+=( $((known_colors[$color] + 40)) )
                fi
                shift;;
            *)
                if [[ -v known_styles[$1] ]]; then
                    attributes+=( "${known_styles["$1"]}" )
                fi
                shift;;
        esac
    done
    printf "\e["
    IFS=";"
    printf '%s' "${attributes[*]}"
    printf "m"
}
