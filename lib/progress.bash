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
    ansi_cursor_save
    ansi_cursor_position_set "$LINES"
    progress_bar "$i" "$n"
    ansi_cursor_restore
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
        RUNNING) STATUS="$(printf "%sRunning%s" "$(ansi_style bold)")";;
        DONE)    STATUS="$(printf "%s   DONE%s" "$(ansi_style fg=green)" "$(ansi_style)")";;
        FAILED)  STATUS="$(printf "%s FAILED%s" "$(ansi_style fg=red)" "$(ansi_style)")";;
        *) echo "Unexpected task status \`$1\`, exiting."; exit 1;;
    esac
    local -r ELAPSED="$(timer_elapsed CURRENT_TASK_TIMER)"
    printf "%s%s [%${tasks_count_len}s/$tasks_count] [%s] %s%s" \
        "$NEWLINE" "$STATUS" "$i" "$ELAPSED" "$TASK" "$(ansi_style)"
}

function print_running_task {
    local task="$1"
    ansi_cursor_save
    ansi_cursor_position_set "$RUNNING_TASK_LINE"
    print_task_status RUNNING
    ansi_cursor_restore
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
        bash ./tests/layer-random/recipes/random/random.bash |& tee "$FIFO" &>"$LOGFILE"
        result=$?
        rm -f "$FIFO" &>/dev/null
        exit $result
    ) &
}


readonly COMMAND_OUTPUT_PREVIEW_LINES=10
readonly BUILD_DIR=build
readonly WORK_DIR="$BUILD_DIR/work"

function _progress_init_term {
    shopt -s checkwinsize
    # Execute a non-builtin command to ensure LINES and COLUMNS are populated
    # Refer to checkwinsize option in the bash manual
    (:)
    ansi_cursor_hide

    readonly PREVIOUSLY_COMPLETED_TASK_LINE=$(( LINES - COMMAND_OUTPUT_PREVIEW_LINES - 2 ))         # 48
    readonly RUNNING_TASK_LINE=$(( LINES - COMMAND_OUTPUT_PREVIEW_LINES - 1 ))                      # 49
    readonly COMMAND_OUTPUT_PREVIEW_START_LINE=$(( LINES - COMMAND_OUTPUT_PREVIEW_LINES ))          # 50
    readonly COMMAND_OUTPUT_PREVIEW_END_LINE=$(( LINES - 1 ))                                       # 59
    readonly PROGRESS_BAR_LINE=$(( LINES ))                                                         # 60

    # Start printing at the bottom of the screen
    ansi_cursor_position_set $LINES
    # Clear the screen by inserting a full page of newlines to avoid overwriting the scrollback buffer
    # TODO just print a bunch of newlines depending on the current cursor position
    tput -x clear
    # Go to the lines where the running task message is printed
    ansi_cursor_position_set $RUNNING_TASK_LINE
}


function _progress_deinit_term {
    ansi_cursor_save
    ansi_scroll_region_set
    ansi_cursor_position_set $LINES 1
    ansi_erase_display_from_cursor_to_bottom
    ansi_cursor_restore
    ansi_cursor_show
}

function progress_run_tasks {
    trap _progress_deinit_term EXIT
    _progress_init_term

    timer_reset GLOBAL_TIMER

    local task_succeeded=0
    local task_failed=0

    for i in "${!tasks[@]}"; do
        local TASK="${tasks[i]}"
        local PACKAGE_NAME="${TASK/ - *}"
        local PACKAGE_TASK="${TASK#* - }"
        (( i += 1 )) # Use one-based index for progress display

        local FIFO="$WORK_DIR/$PACKAGE_NAME/$PACKAGE_TASK"
        local LOGFILE="$WORK_DIR/$PACKAGE_NAME/$PACKAGE_TASK.log"
        local RUNFILE="$WORK_DIR/$PACKAGE_NAME/$PACKAGE_TASK.run"
        prepare_execution_environment "$FIFO" "$LOGFILE" "$RUNFILE"

        timer_reset CURRENT_TASK_TIMER

        ansi_cursor_save
        ansi_scroll_region_set "$COMMAND_OUTPUT_PREVIEW_START_LINE" "$COMMAND_OUTPUT_PREVIEW_END_LINE"
        ansi_cursor_restore

        spawn_task_execution_process "$TASK"

        ansi_cursor_position_set "$COMMAND_OUTPUT_PREVIEW_START_LINE"
        while [[ -p $FIFO ]]; do
            print_running_task "$TASK"

            print_bottom_progress_bar "$i" "$tasks_count"

            ansi_style faint
            if IFS= read -r -t1 line ; then
                printf "%s\n" "$line"
            else # Partial read due to timeout, do not print newline
                printf "%s" "$line"
            fi
            ansi_style
        done < "$FIFO"

        ansi_erase_rect "$COMMAND_OUTPUT_PREVIEW_START_LINE" "" "$COMMAND_OUTPUT_PREVIEW_END_LINE" ""

        ansi_cursor_save
        ansi_scroll_region_set 1 "$PREVIOUSLY_COMPLETED_TASK_LINE"
        ansi_cursor_restore

        ansi_cursor_position_set "$PREVIOUSLY_COMPLETED_TASK_LINE"
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
            "$(ansi_style bold)$tasks_count$(ansi_style)" \
            "$(ansi_style fg=green)all$(ansi_style)"
    elif (( task_succeeded == 0 )); then
        printf "Task summary: executed %s tasks and %s failed.\n" \
            "$(ansi_style bold)$tasks_count$(ansi_style)" \
            "$(ansi_style fg=red)all$(ansi_style)"
    else
        printf "Task summary: executed %s tasks, %s succeeded and %s failed.\n" \
            "$(ansi_style bold)$tasks_count$(ansi_style)" \
            "$(ansi_style fg=green)$task_succeeded$(ansi_style)" \
            "$(ansi_style fg=red)$task_failed$(ansi_style)"
    fi
}
