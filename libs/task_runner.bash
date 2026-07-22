# Associative arrays to store task information
declare -A EC_TASK_DEPENDENCIES=() # task -> space-separated list of dependencies
declare -A EC_TASK_RECIPES=()      # task -> path to task script
declare -A EC_TASK_COMPLETED=()    # task -> exit status (0 on success, non-zero on failure)
declare -A EC_TASK_RUNNING=()      # task -> PID if running
declare -A EC_TASK_TIMER=()        # task -> duration time points

function ec_get_recipe_file_for_package {
    local package="$1"
    local output_var="$2"
    local -a recipe_file=()
    recipe_file+=(recipes/**/"$package".bash)
    if (( ${#recipe_file[@]} > 1 )); then
        ec_log E "  Found more than one recipe for package \`$package\` (total ${#recipe_file[@]}):"
        for file in "${recipe_file[@]}"; do
            ec_log E "    $file"
        done
        return 1
    elif (( ${#recipe_file[@]} == 0 )); then
        ec_log E "No recipe found for package \`$package\`."
        return 1
    fi
    printf -v "$output_var" "%s" "${recipe_file[@]}"
}

function ec_discover_task {
    local -r task_name="$1"
    local -r chain="${2-}"

    # Detect circular dependency: task_name is already an ancestor in the
    # current discovery chain. Bail out immediately, before any task runs.
    local -ar chain_array=("$chain")
    local i
    for ((i = 0; i < ${#chain_array[@]}; i++)); do
        if [[ "${chain_array[$i]}" == "$task_name" ]]; then
            ec_log E "Circular dependency detected: $(ec_join_affix ' -> ' \` \` "${chain_array[@]:i}" "$task_name")"
            exit 1
        fi
    done

    # Skip if already discovered
    [[ -v EC_TASK_RECIPES[$task_name] ]] && return 0

    # Find the task file
    local task_file
    ec_get_recipe_file_for_package "$task_name" task_file || return 1

    ec_log D "  Discovering task: $task_name from $task_file"

    # Store the script path
    EC_TASK_RECIPES["$task_name"]="$task_file"

    # Source the file in a subshell to extract DEPENDS array
    local deps
    deps=$(
        EC_DEPENDS=( "${EC_BASE_DEPENDS[@]}" )
        # TODO handle error when sourcing the recipes
        # shellcheck disable=SC1090
        source "$task_file" 2>/dev/null || true
        echo "${EC_DEPENDS[*]}"
    )

    # Store dependencies (unless --no-deps is set)
    if $EC_SKIP_DEPENDENCIES; then
        EC_TASK_DEPENDENCIES["$task_name"]=""
        ec_log D "    Dependencies: ${deps:-none} (skipped)"
    else
        EC_TASK_DEPENDENCIES["$task_name"]="$deps"
        ec_log D "    Dependencies: ${deps:-none}"

        # Recursively discover dependencies, extending the chain so any
        # cycle further down can be detected against the full ancestry
        local dep
        for dep in $deps; do
            ec_discover_task "$dep" "$chain $task_name"
        done
    fi
}

function ec_discover_tasks {
    local -a target_packages=("$@")

    ec_log D "Discovering tasks for packages $(ec_join_affix ', ' \` \` "${target_packages[@]}")..."

    # Discover each target package and its dependencies
    local succeeded=true
    local package
    for package in "${target_packages[@]}"; do
        if ! ec_discover_task "$package"; then
            succeeded=false
        fi
    done
    $succeeded
}

# Validate that all dependencies exist
function ec_validate_dependencies {
    local validation_failed=0

    local task
    for task in "${!EC_TASK_DEPENDENCIES[@]}"; do
        local deps="${EC_TASK_DEPENDENCIES[$task]}"

        local dep
        for dep in $deps; do
            if [[ ! -v EC_TASK_RECIPES[$dep] ]]; then
                ec_log E "Task \`$task\` depends on \`$dep\`, but \`$dep\` could not be found!"
                validation_failed=1
            fi
        done
    done

    if (( validation_failed == 1 )); then
        exit 1
    fi
}

# Check if all dependencies of a task are completed
function ec_dependencies_satisfied {
    local task="$1"
    local deps="${EC_TASK_DEPENDENCIES[$task]}"

    # No dependencies means ready to run
    [[ -z "$deps" ]] && return 0

    # Check each dependency
    local dep
    for dep in $deps; do
        if [[ ! -v EC_TASK_COMPLETED[$dep] ]]; then
            return 1 # Dependency not completed
        elif (( EC_TASK_COMPLETED[$dep] != 0 )); then
            return 1 # Dependency failed
        fi
    done

    return 0 # All dependencies completed
}

function _ec_prepare_execution_environment {
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

# Execute a task in the background
function _ec_execute_task {
    local task="$1"
    local script="${EC_TASK_RECIPES[$task]}"

    FIFO="$EC_WORK_DIR/$task/$task.fifo"
    LOGFILE="$EC_WORK_DIR/$task/$task.log"
    RUNFILE="$EC_WORK_DIR/$task/$task.run"
    _ec_prepare_execution_environment "$FIFO" "$LOGFILE" "$RUNFILE"

    (
        # Ignore interrupt signals so task continues even when parent is interrupted
        trap '' SIGINT

        exec 19>"$RUNFILE"
        BASH_XTRACEFD=19
        set -x -o pipefail

        # Source the task script
        EC_DEPENDS=()
        # shellcheck disable=SC1090
        source "$script"

        # TODO relink config folder if one is present in files/

        declare -rx D="${EC_DOWNLOADS_DIR}/$task"
        declare -rx W="${EC_WORK_DIR}/$task"
        cd "$W" || exit 1
        if [[ $(type -t ec_do_install) == function ]] && [[ ! -v EC_INSTALL_FROM_DISTRO_PKG_PROVIDER ]]; then
            # ec_do_install |& tee "$FIFO" &>"$LOGFILE"
            # Don't send anything into the fifo yet as nobody is currently reading
            ec_do_install |& tee "$LOGFILE"
        else
            ec_log N "TODO Installing from package provider"
            # TODO loop through all distro package providers
            if [[ -v EC_DISTRO_PKG_PROVIDERS[0] ]]; then
                local -r pkg_provider="${EC_DISTRO_PKG_PROVIDERS[0]}"
                local -r pkg_pattern_ref="EC_PKG_PROVIDER_${pkg_provider}_PKG_PATTERN[$task]"
                local -r pkg_pattern_default="^$task$"
                local -r pkg_pattern="${!pkg_pattern_ref:-$pkg_pattern_default}"
                local installed_pkg
                if installed_pkg=$("ec_${pkg_provider}_pkg_installed" "$pkg_pattern"); then
                    readarray -t installed_pkg <<< "$installed_pkg"
                    ec_log W "Package '$task' already installed with '${pkg_provider}': ${installed_pkg[*]}"
                else
                    ec_log N "TODO installing"
                fi
            else
                ec_log E "No package provider set for distro '$EC_DISTRO'"
            fi
        fi

        result=$?
        rm -f "$FIFO" &>/dev/null
        exit $result
    ) #&

    # Store the PID
    # EC_TASK_RUNNING["$task"]=$!

    # TODO remove
    EC_TASK_COMPLETED["$task"]=$?
}

# Report tasks that can't start because dependencies are unmet or failed
function _ec_report_blocked_tasks {
    local -a blocked_lines=()
    local -a stuck_lines=()
    local task
    for task in "${!EC_TASK_RECIPES[@]}"; do
        [[ -v EC_TASK_COMPLETED[$task] ]] && continue

        local deps="${EC_TASK_DEPENDENCIES[$task]}"
        local -a unmet_deps=()
        local dep
        for dep in $deps; do
            if [[ -v EC_TASK_COMPLETED[$dep] ]]; then
                (( EC_TASK_COMPLETED[$dep] != 0 )) && unmet_deps+=("$dep")
            else
                unmet_deps+=("$dep")
            fi
        done

        if (( ${#unmet_deps[@]} > 0 )); then
            blocked_lines+=("  - \`$task\` cannot run because dependencies did not complete: $(ec_join_affix ', ' \` \` "${unmet_deps[@]}")")
        else
            stuck_lines+=("  - \`$task\` (depends on: $(ec_join_affix ', ' \` \` ${deps:-none}))")
        fi
    done

    if (( ${#blocked_lines[@]} > 0 )); then
        ec_log E "Some tasks cannot run because one or more dependencies did not complete:"
        local line
        for line in "${blocked_lines[@]}"; do
            ec_log E "$line"
        done
    fi

    if (( ${#stuck_lines[@]} > 0 )); then
        ec_log E "No tasks can be started, but none of their dependencies failed. This should not happen and is likely a bug in the task scheduler:"
        local line
        for line in "${stuck_lines[@]}"; do
            ec_log E "$line"
        done
    fi
}

# Main execution loop with dynamic dependency resolution
function ec_execute_tasks {
    ec_log N "Executing tasks..."

    local total_tasks=${#EC_TASK_RECIPES[@]}
    local completed_count=0
    local blocked=false
    local task

    # Reverse mapping: PID -> task name
    declare -A pid_to_task=()

    while (( completed_count < total_tasks )); do
        # Start all tasks whose dependencies are satisfied
        local tasks_started=false
        for task in "${!EC_TASK_RECIPES[@]}"; do
            # Skip if already completed (successfully or not) or running
            [[ -v EC_TASK_COMPLETED[$task] ]] && continue
            [[ -v EC_TASK_RUNNING[$task] ]] && continue
            (( ${#EC_TASK_RUNNING[@]} >= EC_JOBS_COUNT )) && continue

            # Check if dependencies are satisfied
            if ec_dependencies_satisfied "$task"; then
                ec_log N "Starting task '$task'..."
                _ec_execute_task "$task"
                # local pid="${EC_TASK_RUNNING["$task"]}"
                # pid_to_task["$pid"]="$task"
                tasks_started=true
            fi
        done

        # If no tasks are running and none could start, we have a problem
        local running_count=${#EC_TASK_RUNNING[@]}
        if (( running_count == 0 )); then
            if ! $tasks_started; then
                blocked=true
                break
            fi
            continue
        fi

        # Wait for any single task to complete
        # local completed_pid
        # local task_status=0
        # # || is important here as errexit option is set
        # wait -n -p completed_pid "${EC_TASK_RUNNING[@]}" || task_status=$?
        # if [[ -v pid_to_task[$completed_pid] ]]; then
        #     local completed_task="${pid_to_task[$completed_pid]}"
        #     local elapsed_time
        #     elapsed_time=$(timer_elapsed EC_TASK_TIMER["$completed_task"])
        #     EC_TASK_COMPLETED["$completed_task"]=$task_status
        #     unset "EC_TASK_RUNNING[$completed_task]"
        #     unset "pid_to_task[$completed_pid]"
        #     completed_count=$((completed_count + 1))
        #     ec_post_rendering_event task_completed "$completed_task|$completed_pid|$elapsed_time|$task_status"
        # fi
    done

    local -a failed_tasks=()
    for task in "${!EC_TASK_COMPLETED[@]}"; do
        (( EC_TASK_COMPLETED[$task] != 0 )) && failed_tasks+=("$task")
    done
    if (( ${#failed_tasks[@]} > 0 )); then
        ec_log E "Some tasks failed: $(ec_join_affix ', ' \` \` "${failed_tasks[@]}")."
    fi

    if $blocked; then
        _ec_report_blocked_tasks
    fi

    if $blocked || (( ${#failed_tasks[@]} > 0 )); then
        exit 1
    fi

    ec_log N "All tasks completed successfully!"
}
