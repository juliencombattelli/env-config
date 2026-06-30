
if [[ ${DEBUG:-0} == 1 ]]; then
    exec 20>debug.log
    BASH_XTRACEFD=20
    set -x
    function breakpoint {
        echo "$(caller)" >> /dev/null # No need to send this line to debug.log as xtrace is enabled
        read -s -r -dn
        printf "\n\n" >> debug.log
    }
else
    function breakpoint {
        :
    }
fi

function vt100_cursor_show {
    printf "\e[?25h"
}

function vt100_cursor_hide {
    printf "\e[?25l"
}

function vt100_cursor_save {
    printf "\e7"
}

function vt100_cursor_restore {
    printf "\e8"
}

function vt100_cursor_position_get {
    IFS='[;' read -p $'\e[6n' -d R -rs _ "$1" "$2" _
}

function vt100_cursor_position_set {
    printf "\e[%s;%sH" "$1" "$2"
}

function vt100_cursor_up {
    printf "\e[%sA" "$1"
}

function vt100_cursor_down {
    printf "\e[%sB" "$1"
}

function vt100_scroll_up {
    printf "\e[%sS" "$1"
}

function vt100_scroll_down {
    printf "\e[%sT" "$1"
}

function vt100_scroll_region_set {
    printf "\e[%s;%sr" "$1" "$2"
}

function vt100_scroll_region_reset {
    vt100_cursor_save
    vt100_scroll_region_set
    vt100_cursor_restore
}

function vt100_erase_rect {
    # shellcheck disable=SC2016 # use single quotes to avoid escaping $
    printf '\e[%s;%s;%s;%s$z' "$1" "$2" "$3" "$4"
}

function vt100_erase_display_from_cursor_to_bottom {
    printf "\e[0J"
}

function vt100_erase_display_from_top_to_cursor {
    printf "\e[1J"
}

function vt100_erase_display {
    printf "\e[2J"
}

function vt100_erase_line_from_cursor_to_right {
    printf "\e[0K"
}

function vt100_erase_line_from_cursor_to_left {
    printf "\e[1K"
}

function vt100_erase_line {
    printf "\e[2K"
}

# TODO consider using https://github.com/fidian/ansi
# readonly VT100_STYLE_RESET=0
readonly VT100_STYLE_BOLD=1
readonly VT100_STYLE_FAINT=2
# readonly VT100_STYLE_ITALIC=3
# readonly VT100_STYLE_UNDERLINE=4
# readonly VT100_STYLE_SLOW_BLINK=5
# readonly VT100_STYLE_RAPID_BLINK=6
# readonly VT100_STYLE_REVERSE=7
# readonly VT100_STYLE_CONCEAL=8
# readonly VT100_STYLE_STRIKETHROUGH=9
# readonly VT100_STYLE_FONT0=10
# readonly VT100_STYLE_FONT1=11
# readonly VT100_STYLE_FONT2=12
# readonly VT100_STYLE_FONT3=13
# readonly VT100_STYLE_FONT4=14
# readonly VT100_STYLE_FONT5=15
# readonly VT100_STYLE_FONT6=16
# readonly VT100_STYLE_FONT7=17
# readonly VT100_STYLE_FONT8=18
# readonly VT100_STYLE_FONT9=19
# readonly VT100_STYLE_FRACTUR=20
# readonly VT100_STYLE_BOLD_OFF=21
# readonly VT100_STYLE_NORMAL=22
# readonly VT100_STYLE_NO_ITALIC=23
# readonly VT100_STYLE_NO_UNDERLINE=24
# readonly VT100_STYLE_NO_BLINK=25
# readonly VT100_STYLE_RESERVED26=26
# readonly VT100_STYLE_NO_INVERSE=27
# readonly VT100_STYLE_NO_CONCEAL=28
# readonly VT100_STYLE_NO_STRIKETHROUGH=29
# readonly VT100_STYLE_FG_BLACK=30
readonly VT100_STYLE_FG_RED=31
readonly VT100_STYLE_FG_GREEN=32
# readonly VT100_STYLE_FG_YELLOW=33
# readonly VT100_STYLE_FG_BLUE=34
# readonly VT100_STYLE_FG_MAGENTA=35
# readonly VT100_STYLE_FG_CYAN=36
# readonly VT100_STYLE_FG_WHITE=37
# readonly VT100_STYLE_RESERVED38=38
# readonly VT100_STYLE_RESERVED39=39
# readonly VT100_STYLE_BG_BLACK=40
# readonly VT100_STYLE_BG_RED=41
# readonly VT100_STYLE_BG_GREEN=42
# readonly VT100_STYLE_BG_YELLOW=43
# readonly VT100_STYLE_BG_BLUE=44
# readonly VT100_STYLE_BG_MAGENTA=45
# readonly VT100_STYLE_BG_CYAN=46
# readonly VT100_STYLE_BG_WHITE=47
# readonly VT100_STYLE_BG_RESERVED48=48
# readonly VT100_STYLE_BG_RESERVED49=49

function vt100_style_set {
    printf "\e["
    IFS=";"
    printf '%s' "$*"
    printf "m"
}

function vt100_style_reset {
    printf "\e[m"
}

function timer_supports_epochrealtime {
    [[ "$EPOCHREALTIME" =~ ^[0-9]+\.[0-9]+$ ]]
}

function timer_reset {
    local timer_var=${1:-TIMER_START}
    if timer_supports_epochrealtime; then
        # Bash 5+: store microseconds since epoch (strip the dot)
        printf -v "$timer_var" '%s' "${EPOCHREALTIME/.}"
    else
        # Bash 4: second resolution only
        printf -v "$timer_var" '%s' "$SECONDS"
    fi
}

function timer_elapsed {
    local timer_var=${1:-TIMER_START}
    local timer_start=${!timer_var}
    local elapsed_sec
    local ms=""
    if timer_supports_epochrealtime; then
        local elapsed_us=$(( ${EPOCHREALTIME/.} - timer_start ))
        elapsed_sec=$(( elapsed_us / 1000000 ))
        ms=$(printf ".%03d" $(( ( elapsed_us / 1000 ) % 1000 )))
    else
        elapsed_sec=$(( SECONDS - timer_start ))
    fi
    local h=$(( elapsed_sec / 3600 ))
    local m=$(( ( elapsed_sec % 3600 ) / 60 ))
    local s=$(( elapsed_sec % 60 ))
    printf "%02d:%02d:%02d%s\n" $h $m $s $ms
}

function progress_bar {
    local ms=0
    if timer_supports_epochrealtime; then
        ms=4
    fi
    # Progress: xxx% ████████░░░░░░░ HH:MM:SS.mmm<blank>
    local BAR_LEN=$(( COLUMNS - 10 - 5 - 10 - $ms ))
    local progress_percent=$(( $1 * 100 / $2 ))
    local done=$(( progress_percent * BAR_LEN / 100 ))
    local left=$(( BAR_LEN - done ))
    # shellcheck disable=SC2155
    local fill=$(printf "%${done}s")
    # shellcheck disable=SC2155
    local empty=$(printf "%${left}s")
    printf "Progress: %3s%% %s%s %s " "$progress_percent" "${fill// /█}" "${empty// /░}" "$(timer_elapsed GLOBAL_TIMER)"
}

function print_bottom_progress_bar {
    local i="$1"
    local n="$2"
    vt100_cursor_save
    vt100_cursor_position_set "$LINES"
    progress_bar "$i" "$n"
    vt100_cursor_restore
}

function print_task_status {
    if [[ "$1" == "-n" ]]; then
        local -r NEWLINE=$'\n' # Prepend a newline to the line
        shift
    else
        local -r NEWLINE=$'\r\033[K' # Overwrite the current line
    fi
    local STATUS
    case "$1" in
        RUNNING) STATUS="$(printf "%sRunning%s" "$(vt100_style_set $VT100_STYLE_BOLD)" "$(vt100_style_reset)")";;
        DONE)    STATUS="$(printf "%s   DONE%s" "$(vt100_style_set $VT100_STYLE_FG_GREEN)" "$(vt100_style_reset)")";;
        FAILED)  STATUS="$(printf "%s FAILED%s" "$(vt100_style_set $VT100_STYLE_FG_RED)" "$(vt100_style_reset)")";;
        *) echo "Unexpected task status \`$1\`, exiting."; exit 1;;
    esac
    local -r ELAPSED="$(timer_elapsed CURRENT_TASK_TIMER)"
    printf "%s%s [%${tasks_count_len}s/$tasks_count] [%s] %s" \
        "$NEWLINE" "$STATUS" "$i" "$ELAPSED" "$TASK"
}

function print_running_task {
    local task="$1"
    vt100_cursor_save
    vt100_cursor_position_set "$RUNNING_TASK_LINE"
    print_task_status RUNNING
    vt100_cursor_restore
}

function prepare_execution_environment {
    local FIFO="$1"
    local LOGFILE="$2"
    local RUNFILE="$3"

    mkdir -p "$(dirname "$FIFO")"
    rm -f "$FIFO"
    mkfifo "$FIFO"

    mkdir -p "$(dirname "$LOGFILE")"
    rm -f "$LOGFILE"

    mkdir -p "$(dirname "$RUNFILE")"
    rm -f "$RUNFILE"
}

function spawn_task_execution_process {
    (
        exec 19>"$RUNFILE"
        BASH_XTRACEFD=19
        set -x -o pipefail
        # Network connectivity tests: sudo -- apt-get -o APT::Update::Error-Mode=any update
        bash ./tests/layer-random/recipes/random/random.bash |& tee "$FIFO" &>"$LOGFILE"
        result=$?
        rm -f "$FIFO" &>/dev/null
        exit $result
    ) &
}

COMMAND_OUTPUT_PREVIEW_LINES=10
BUILD_DIR=build
WORK_DIR="$BUILD_DIR/work"

tasks=(
    "openssh-server - do_install"
    "openssh-server - do_configure"
    "ssh - do_install"
    "ssh - do_configure"
    "wget - do_install"
    "wget - do_configure"
    "x11fwd - do_install"
    "x11fwd - do_configure"
    "all - do_install"
    "all - do_configure"
    "null - do_install"
    "null - do_configure"
    "wsl - do_install"
    "wsl - do_configure"
    "pip - do_install"
    "pip - do_configure"
    "apt - do_install"
    "apt - do_configure"
    "winget - do_install"
    "winget - do_configure"
    "gdb-dashboard - do_install"
    "gdb-dashboard - do_configure"
    "gdb - do_install"
    "gdb - do_configure"
    "make - do_install"
    "make - do_configure"
    "gcc - do_install"
    "gcc - do_configure"
    "ninja - do_install"
    "ninja - do_configure"
    "ccmake - do_install"
    "ccmake - do_configure"
    "cmake - do_install"
    "cmake - do_configure"
    "rust - do_install"
    "rust - do_configure"
    "clang - do_install"
    "clang - do_configure"
    "clang-tidy - do_install"
    "clang-tidy - do_configure"
    "clang-format - do_install"
    "clang-format - do_configure"
    "zig - do_install"
    "zig - do_configure"
    "repo-aliases - do_install"
    "repo-aliases - do_configure"
    "git - do_install"
    "git - do_configure"
    "commit-editor - do_install"
    "commit-editor - do_configure"
    "diff-so-fancy - do_install"
    "diff-so-fancy - do_configure"
    "xterm - do_install"
    "xterm - do_configure"
    "wt - do_install"
    "wt - do_configure"
    "konsole - do_install"
    "konsole - do_configure"
    "tmux - do_install"
    "tmux - do_configure"
    "requests-ca-bundle - do_install"
    "requests-ca-bundle - do_configure"
    "dircolors - do_install"
    "dircolors - do_configure"
    "aliases - do_install"
    "aliases - do_configure"
    "zsh - do_install"
    "zsh - do_configure"
    "oh-my-zsh - do_install"
    "oh-my-zsh - do_configure"
    "powershell - do_install"
    "powershell - do_configure"
    "oh-my-posh - do_install"
    "oh-my-posh - do_configure"
    "bash - do_install"
    "bash - do_configure"
    "proxy - do_install"
    "proxy - do_configure"
    "shell-common - do_install"
    "shell-common - do_configure"
    "scdoc - do_install"
    "scdoc - do_configure"
    "libfuse2 - do_install"
    "libfuse2 - do_configure"
    "vscode - do_install"
    "vscode - do_configure"
    "neovim - do_install"
    "neovim - do_configure"
    "vim - do_install"
    "vim - do_configure"
    "fd - do_install"
    "fd - do_configure"
    "bat - do_install"
    "bat - do_configure"
    "exa - do_install"
    "exa - do_configure"
    "ripgrep - do_install"
    "ripgrep - do_configure"
    "eza - do_install"
    "eza - do_configure"
    "nvimpager - do_install"
    "nvimpager - do_configure"
    "less - do_install"
    "less - do_configure"
)
tasks_count=${#tasks[@]}
tasks_count_len=${#tasks_count}

function deinit_term {
    vt100_cursor_save
    vt100_scroll_region_set
    vt100_cursor_position_set $LINES 1
    vt100_erase_display_from_cursor_to_bottom
    vt100_cursor_restore
    vt100_cursor_show
}

function init_term {
    shopt -s checkwinsize
    # Execute a non-builtin command to ensure LINES and COLUMNS are populated
    # Refer to checkwinsize option in the bash manual
    (:)
    vt100_cursor_hide

    readonly PREVIOUSLY_COMPLETED_TASK_LINE=$(( LINES - COMMAND_OUTPUT_PREVIEW_LINES - 2 ))         # 48
    readonly RUNNING_TASK_LINE=$(( LINES - COMMAND_OUTPUT_PREVIEW_LINES - 1 ))                      # 49
    readonly COMMAND_OUTPUT_PREVIEW_START_LINE=$(( LINES - COMMAND_OUTPUT_PREVIEW_LINES ))          # 50
    readonly COMMAND_OUTPUT_PREVIEW_END_LINE=$(( LINES - 1 ))                                       # 59
    readonly PROGRESS_BAR_LINE=$(( LINES ))                                                         # 60

    # Start printing at the bottom of the screen
    vt100_cursor_position_set $LINES
    # Clear the screen by inserting a full page of newlines to avoid overwriting the scrollback buffer
    tput -x clear
    # Go to the lines where the running task message is printed
    vt100_cursor_position_set $RUNNING_TASK_LINE
}

function main {
    trap deinit_term EXIT
    init_term

    timer_reset GLOBAL_TIMER

    task_succeeded=0
    task_failed=0

    for i in "${!tasks[@]}"; do
        TASK="${tasks[i]}"
        PACKAGE_NAME="${TASK/ - *}"
        PACKAGE_TASK="${TASK#* - }"
        (( i += 1 )) # Use one-based index for progress display

        FIFO="$WORK_DIR/$PACKAGE_NAME/$PACKAGE_TASK"
        LOGFILE="$WORK_DIR/$PACKAGE_NAME/$PACKAGE_TASK.log"
        RUNFILE="$WORK_DIR/$PACKAGE_NAME/$PACKAGE_TASK.run"
        prepare_execution_environment "$FIFO" "$LOGFILE" "$RUNFILE"

        timer_reset CURRENT_TASK_TIMER

        vt100_cursor_save
        vt100_scroll_region_set "$COMMAND_OUTPUT_PREVIEW_START_LINE" "$COMMAND_OUTPUT_PREVIEW_END_LINE"
        vt100_cursor_restore

        spawn_task_execution_process "$TASK"

        vt100_cursor_position_set "$COMMAND_OUTPUT_PREVIEW_START_LINE"
        while [[ -p $FIFO ]]; do
            print_running_task "$TASK"

            print_bottom_progress_bar "$i" "$tasks_count"

            vt100_style_set $VT100_STYLE_FAINT
            if IFS= read -r -t1 line ; then
                printf "%s\n" "$line"
            else # Partial read due to timeout, do not print newline
                printf "%s" "$line"
            fi
            vt100_style_reset
        done < "$FIFO"

        vt100_erase_rect "$COMMAND_OUTPUT_PREVIEW_START_LINE" "" "$COMMAND_OUTPUT_PREVIEW_END_LINE" ""

        vt100_cursor_save
        vt100_scroll_region_set 1 "$PREVIOUSLY_COMPLETED_TASK_LINE"
        vt100_cursor_restore

        vt100_cursor_position_set "$PREVIOUSLY_COMPLETED_TASK_LINE"
        TIME_TOOK="$(timer_elapsed CURRENT_TASK_TIMER)"
        if wait %1; then
            VERDICT=DONE
            (( task_succeeded += 1 ))
        else
            VERDICT=FAILED
            (( task_failed += 1 ))
        fi

        print_task_status -n "$VERDICT"
    done

    printf "\n────────────\n"
    if (( task_failed == 0 )); then
        printf "Task summary: executed %s tasks and %s succeeded.\n" \
            "$(vt100_style_set $VT100_STYLE_BOLD)$tasks_count$(vt100_style_reset)" \
            "$(vt100_style_set $VT100_STYLE_FG_GREEN)all$(vt100_style_reset)"
    elif (( task_succeeded == 0 )); then
        printf "Task summary: executed %s tasks and %s failed.\n" \
            "$(vt100_style_set $VT100_STYLE_BOLD)$tasks_count$(vt100_style_reset)" \
            "$(vt100_style_set $VT100_STYLE_FG_RED)all$(vt100_style_reset)"
    else
        printf "Task summary: executed %s tasks, %s succeeded and %s failed.\n" \
            "$(vt100_style_set $VT100_STYLE_BOLD)$tasks_count$(vt100_style_reset)" \
            "$(vt100_style_set $VT100_STYLE_FG_GREEN)$task_succeeded$(vt100_style_reset)" \
            "$(vt100_style_set $VT100_STYLE_FG_RED)$task_failed$(vt100_style_reset)"
    fi
}

if ! (return 0 2>/dev/null); then
    main
fi
