
function progress_init_term {
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


function progress_deinit_term {
    ansi_cursor_save
    ansi_scroll_region_set
    ansi_cursor_position_set $LINES 1
    ansi_erase_display_from_cursor_to_bottom
    ansi_cursor_restore
    ansi_cursor_show
}
