
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

# Wall-clock epoch (whole seconds). Unlike timer_reset/timer_elapsed (which
# store an in-process timer variable), this can be safely shared between the
# scheduler and the renderer, which run in separate subshells/processes and
# do not share shell variables.
function epoch_now_seconds {
    date +%s
}

function format_hms {
    local total_sec="$1"
    printf "%02d:%02d:%02d" $(( total_sec / 3600 )) $(( ( total_sec % 3600 ) / 60 )) $(( total_sec % 60 ))
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
        RUNNING) STATUS="$(printf "%sRunning%s" "$(vt100_style_set $VT100_STYLE_BOLD)")";;
        DONE)    STATUS="$(printf "%s   DONE%s" "$(vt100_style_set $VT100_STYLE_FG_GREEN)" "$(vt100_style_reset)")";;
        FAILED)  STATUS="$(printf "%s FAILED%s" "$(vt100_style_set $VT100_STYLE_FG_RED)" "$(vt100_style_reset)")";;
        *) echo "Unexpected task status \`$1\`, exiting."; exit 1;;
    esac
    local -r ELAPSED="$(timer_elapsed CURRENT_TASK_TIMER)"
    printf "%s%s [%${tasks_count_len}s/$tasks_count] [%s] %s%s" \
        "$NEWLINE" "$STATUS" "$i" "$ELAPSED" "$TASK" "$(vt100_style_reset)"
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

function prepare_execution_environment_parallel {
    local LOGFILE="$1"
    local RUNFILE="$2"

    mkdir -p "$(dirname "$LOGFILE")"
    rm -f "$LOGFILE"

    mkdir -p "$(dirname "$RUNFILE")"
    rm -f "$RUNFILE"
}

function spawn_task_execution_process_parallel {
    local LOGFILE="$1"
    local RUNFILE="$2"
    (
        exec 19>"$RUNFILE"
        BASH_XTRACEFD=19
        set -x -o pipefail
        # Network connectivity tests: sudo -- apt-get -o APT::Update::Error-Mode=any update
        bash ./tests/layer-random/recipes/random/random.bash &>"$LOGFILE"
    ) &
}

# Maximum number of tasks to run concurrently.
# When <= 1, the original single-task progress display (with command output
# preview) is used. When >= 2, the command output preview is dropped and one
# running line per concurrent task is displayed instead.
MAX_CONCURRENT_JOBS=8

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

# Files used to hand off state between the scheduler (run_tasks_parallel) and
# the renderer (render_loop_parallel), which run concurrently as independent
# processes and therefore cannot share shell variables directly.
PROGRESS_STATE_DIR="$WORK_DIR/.progress"
SLOTS_STATE_FILE="$PROGRESS_STATE_DIR/slots.state"
EVENTS_LOG_FILE="$PROGRESS_STATE_DIR/events.log"
PROGRESS_COUNT_FILE="$PROGRESS_STATE_DIR/progress.count"
FINISHED_FLAG_FILE="$PROGRESS_STATE_DIR/finished"

function init_progress_state {
    rm -rf "$PROGRESS_STATE_DIR"
    mkdir -p "$PROGRESS_STATE_DIR"
    : > "$SLOTS_STATE_FILE"
    : > "$EVENTS_LOG_FILE"
    printf '0' > "$PROGRESS_COUNT_FILE"
}

# Write to a file by writing to a temp file and renaming it into place, so
# a concurrently running reader never observes a partially written file.
function atomic_write {
    local target="$1"
    local content="$2"
    local tmp="$target.tmp.$$"
    printf '%s' "$content" > "$tmp"
    mv -f "$tmp" "$target"
}

function deinit_term {
    vt100_cursor_save
    vt100_scroll_region_set
    vt100_cursor_position_set $LINES 1
    vt100_erase_display_from_cursor_to_bottom
    vt100_cursor_restore
    vt100_cursor_show
}

function init_term_common {
    shopt -s checkwinsize
    # Execute a non-builtin command to ensure LINES and COLUMNS are populated
    # Refer to checkwinsize option in the bash manual
    (:)
    vt100_cursor_hide

    # Start printing at the bottom of the screen
    vt100_cursor_position_set $LINES
    # Clear the screen by inserting a full page of newlines to avoid overwriting the scrollback buffer
    tput -x clear
}

function init_term {
    init_term_common

    readonly PREVIOUSLY_COMPLETED_TASK_LINE=$(( LINES - COMMAND_OUTPUT_PREVIEW_LINES - 2 ))         # 48
    readonly RUNNING_TASK_LINE=$(( LINES - COMMAND_OUTPUT_PREVIEW_LINES - 1 ))                      # 49
    readonly COMMAND_OUTPUT_PREVIEW_START_LINE=$(( LINES - COMMAND_OUTPUT_PREVIEW_LINES ))          # 50
    readonly COMMAND_OUTPUT_PREVIEW_END_LINE=$(( LINES - 1 ))                                       # 59
    readonly PROGRESS_BAR_LINE=$(( LINES ))                                                         # 60

    # Go to the lines where the running task message is printed
    vt100_cursor_position_set $RUNNING_TASK_LINE
}

# Layout used when MAX_CONCURRENT_JOBS >= 2: no command output preview, one
# running-task line per concurrent job, and a scrolling history region above
# them for completed tasks.
function init_term_parallel {
    init_term_common

    readonly PREVIOUSLY_COMPLETED_TASK_LINE=$(( LINES - MAX_CONCURRENT_JOBS - 1 ))
    readonly RUNNING_TASK_LINE_FIRST=$(( LINES - MAX_CONCURRENT_JOBS ))
    readonly PROGRESS_BAR_LINE=$(( LINES ))

    # Keep the completed-tasks history scrolling within its own region so it
    # never overwrites the fixed running-task lines and progress bar below it.
    vt100_scroll_region_set 1 "$PREVIOUSLY_COMPLETED_TASK_LINE"

    vt100_cursor_position_set "$RUNNING_TASK_LINE_FIRST"
}

function run_tasks_serial {
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
}

# Print (or refresh) the status line for the task running in a given slot.
# elapsed_str is a preformatted HH:MM:SS string, computed by the caller from
# a wall-clock epoch (see epoch_now_seconds/format_hms) rather than an
# in-process timer variable, so this can be called from the renderer even
# though the task was started by a different process.
function print_running_slot {
    local slot="$1"
    local idx="$2"
    local task="$3"
    local elapsed_str="$4"
    vt100_cursor_save
    vt100_cursor_position_set "$(( RUNNING_TASK_LINE_FIRST + slot ))"
    vt100_erase_line
    printf "%s [%${tasks_count_len}s/$tasks_count] [%s] %s%s" \
        "$(printf "%sRunning%s" "$(vt100_style_set $VT100_STYLE_BOLD)" "$(vt100_style_reset)")" \
        "$idx" "$elapsed_str" "$task" "$(vt100_style_reset)"
    vt100_cursor_restore
}

# Blank out a running-task slot once it becomes free.
function clear_running_slot {
    local slot="$1"
    vt100_cursor_save
    vt100_cursor_position_set "$(( RUNNING_TASK_LINE_FIRST + slot ))"
    vt100_erase_line
    vt100_cursor_restore
}

# Append a finished task's status to the scrolling history region.
# elapsed_str is a preformatted HH:MM:SS string (see print_running_slot).
function print_completed_task_parallel {
    local idx="$1"
    local verdict="$2"
    local task="$3"
    local elapsed_str="$4"
    local STATUS
    case "$verdict" in
        DONE)    STATUS="$(printf "%s   DONE%s" "$(vt100_style_set $VT100_STYLE_FG_GREEN)" "$(vt100_style_reset)")";;
        FAILED)  STATUS="$(printf "%s FAILED%s" "$(vt100_style_set $VT100_STYLE_FG_RED)" "$(vt100_style_reset)")";;
        *) echo "Unexpected task status \`$verdict\`, exiting."; exit 1;;
    esac
    vt100_cursor_save
    vt100_cursor_position_set "$PREVIOUSLY_COMPLETED_TASK_LINE"
    printf "\n%s [%${tasks_count_len}s/$tasks_count] [%s] %s%s" \
        "$STATUS" "$idx" "$elapsed_str" "$task" "$(vt100_style_reset)"
    vt100_cursor_restore
}

# --- Scheduler-side state writers -------------------------------------
# These only ever write plain state files; they contain no rendering logic
# and know nothing about screen geometry. This is what lets the scheduler
# (run_tasks_parallel) and the renderer (render_loop_parallel) run fully
# decoupled, each in its own process, coordinating only through files.

# Rewrites the slots-state file from the given slot associative arrays
# (name-references, so the caller's arrays are read without copying them).
function write_slots_state {
    local -n _task_ref="$1"
    local -n _idx_ref="$2"
    local -n _epoch_ref="$3"
    local content=""
    local slot
    for slot in "${!_task_ref[@]}"; do
        content+="$slot"$'\t'"${_idx_ref[$slot]}"$'\t'"${_task_ref[$slot]}"$'\t'"${_epoch_ref[$slot]}"$'\n'
    done
    atomic_write "$SLOTS_STATE_FILE" "$content"
}

function write_progress_count {
    atomic_write "$PROGRESS_COUNT_FILE" "$1"
}

# Appends one completed-task record. Append-only, so no atomic-rename dance
# is needed: each line is short enough to be written atomically by the OS.
function append_event {
    local idx="$1" verdict="$2" task="$3" elapsed_str="$4"
    printf '%s\t%s\t%s\t%s\n' "$idx" "$verdict" "$task" "$elapsed_str" >> "$EVENTS_LOG_FILE"
}

# --- Renderer -----------------------------------------------------------
# Runs as an independent background process, on its own timer, reading only
# the state files written above. It never talks to the scheduler directly,
# so it stays responsive (smooth elapsed-time refresh) regardless of when
# tasks happen to start or finish.

# Redraws every running-slot line from the current contents of the
# slots-state file, blanking out any slot not currently occupied.
function render_slots_parallel {
    local -A occupied=()
    if [[ -s "$SLOTS_STATE_FILE" ]]; then
        local slot idx task start_epoch
        while IFS=$'\t' read -r slot idx task start_epoch; do
            [[ -z "$slot" ]] && continue
            occupied[$slot]=1
            print_running_slot "$slot" "$idx" "$task" "$(format_hms $(( $(epoch_now_seconds) - start_epoch )))"
        done < "$SLOTS_STATE_FILE"
    fi
    local slot
    for (( slot = 0; slot < MAX_CONCURRENT_JOBS; slot++ )); do
        [[ -v occupied[$slot] ]] || clear_running_slot "$slot"
    done
}

# Prints any events appended to the events log since the last call.
# consumed_var is the name of a caller-owned variable tracking how many
# lines have already been rendered.
function render_new_events_parallel {
    local -n _consumed_ref="$1"
    [[ -f "$EVENTS_LOG_FILE" ]] || return 0
    local total_lines
    total_lines=$(wc -l < "$EVENTS_LOG_FILE")
    (( total_lines <= _consumed_ref )) && return 0
    local idx verdict task elapsed_str
    while IFS=$'\t' read -r idx verdict task elapsed_str; do
        print_completed_task_parallel "$idx" "$verdict" "$task" "$elapsed_str"
    done < <(tail -n "+$(( _consumed_ref + 1 ))" "$EVENTS_LOG_FILE")
    _consumed_ref=$total_lines
}

# Renders slots, new events and the progress bar until FINISHED_FLAG_FILE
# appears, then does one last render pass to catch any trailing update.
function render_loop_parallel {
    local events_consumed=0
    local completed_count=0
    while true; do
        render_slots_parallel
        render_new_events_parallel events_consumed
        completed_count="$(<"$PROGRESS_COUNT_FILE")"
        print_bottom_progress_bar "$completed_count" "$tasks_count"

        [[ -f "$FINISHED_FLAG_FILE" ]] && break
        sleep 0.2
    done

    render_slots_parallel
    render_new_events_parallel events_consumed
    completed_count="$(<"$PROGRESS_COUNT_FILE")"
    print_bottom_progress_bar "$completed_count" "$tasks_count"
}

# --- Scheduler ------------------------------------------------------------
# Runs up to MAX_CONCURRENT_JOBS tasks at a time. Dependencies between tasks
# are not handled: tasks are simply started in array order as slots free up.
# Contains no rendering/vt100 calls: it only spawns tasks and publishes its
# state to files for the independently running renderer to pick up.
function run_tasks_parallel {
    declare -A slot_task=()  # slot -> task string
    declare -A slot_idx=()   # slot -> one-based task index
    declare -A slot_epoch=() # slot -> wall-clock start epoch (seconds)
    declare -A pid_slot=()   # pid -> slot
    declare -A pid_idx=()    # pid -> one-based task index
    declare -A pid_task=()   # pid -> task string
    declare -A pid_epoch=()  # pid -> wall-clock start epoch (seconds)

    local next_task_index=0
    local completed_count=0

    while (( completed_count < tasks_count )); do
        # Start tasks to fill any free slot
        local started_any=0
        local slot
        for (( slot = 0; slot < MAX_CONCURRENT_JOBS; slot++ )); do
            [[ -v slot_task[$slot] ]] && continue
            (( next_task_index >= tasks_count )) && break

            TASK="${tasks[next_task_index]}"
            PACKAGE_NAME="${TASK/ - *}"
            PACKAGE_TASK="${TASK#* - }"
            (( next_task_index += 1 ))
            local idx=$next_task_index

            LOGFILE="$WORK_DIR/$PACKAGE_NAME/$PACKAGE_TASK.log"
            RUNFILE="$WORK_DIR/$PACKAGE_NAME/$PACKAGE_TASK.run"
            prepare_execution_environment_parallel "$LOGFILE" "$RUNFILE"

            spawn_task_execution_process_parallel "$LOGFILE" "$RUNFILE"
            local pid=$!
            local start_epoch
            start_epoch=$(epoch_now_seconds)

            slot_task[$slot]="$TASK"
            slot_idx[$slot]="$idx"
            slot_epoch[$slot]="$start_epoch"
            pid_slot[$pid]="$slot"
            pid_idx[$pid]="$idx"
            pid_task[$pid]="$TASK"
            pid_epoch[$pid]="$start_epoch"

            started_any=1
        done

        (( started_any )) && write_slots_state slot_task slot_idx slot_epoch

        local completed_pid
        local task_status=0
        wait -n -p completed_pid || task_status=$?

        [[ -v pid_task[$completed_pid] ]] || continue

        local slot="${pid_slot[$completed_pid]}"
        local idx="${pid_idx[$completed_pid]}"
        local task="${pid_task[$completed_pid]}"
        local start_epoch="${pid_epoch[$completed_pid]}"

        (( completed_count += 1 ))
        if (( task_status == 0 )); then
            VERDICT=DONE
            (( task_succeeded += 1 ))
        else
            VERDICT=FAILED
            (( task_failed += 1 ))
        fi

        append_event "$idx" "$VERDICT" "$task" "$(format_hms $(( $(epoch_now_seconds) - start_epoch )))"

        unset "slot_task[$slot]" "slot_idx[$slot]" "slot_epoch[$slot]"
        unset "pid_slot[$completed_pid]" "pid_idx[$completed_pid]" "pid_task[$completed_pid]" "pid_epoch[$completed_pid]"

        write_slots_state slot_task slot_idx slot_epoch
        write_progress_count "$completed_count"
    done
}

function print_summary {
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

function main {
    trap deinit_term EXIT

    timer_reset GLOBAL_TIMER

    task_succeeded=0
    task_failed=0

    if (( MAX_CONCURRENT_JOBS <= 1 )); then
        init_term
        run_tasks_serial
    else
        init_term_parallel
        init_progress_state

        render_loop_parallel &
        local renderer_pid=$!

        run_tasks_parallel

        touch "$FINISHED_FLAG_FILE"
        wait "$renderer_pid"
    fi

    print_summary
}

if ! (return 0 2>/dev/null); then
    main
fi
