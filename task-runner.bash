#!/usr/bin/env bash

set -euo pipefail
shopt -s globstar nullglob

# Associative arrays to store task information
declare -A TASK_DEPENDENCIES=() # task -> space-separated list of dependencies
declare -A TASK_SCRIPTS=()      # task -> path to task script
declare -A TASK_COMPLETED=()    # task -> 1 if completed
declare -A TASK_RUNNING=()      # task -> PID if running

readonly JOBS_COUNT=64

function ec_wait_background_processes {
    local silent="${1:-}"
    local remaining=${#TASK_RUNNING[@]}
    while (( $remaining > 0 )); do
        if [[ "$silent" != "silent" ]]; then
            echo "Waiting for $remaining background process(es) to complete..."
        fi
        wait -n 2>/dev/null || true
        remaining=$((remaining - 1))
    done
}

function ec_kill_background_processes {
    local -a background_jobs
    readarray -t background_jobs < <(jobs -p)
    if (( ${#background_jobs[@]} > 0 )); then
        echo "Killing all background jobs" >&2
        kill "${background_jobs[@]}" >&2
    fi
}

function ec_discover_tasks {
    local tasks_dir="$1"
    echo "Discovering tasks in $tasks_dir..."

    for task_file in "$tasks_dir"/**/*.bash; do
        [[ -f "$task_file" ]] || continue

        # Get task name from filename (remove .bash extension)
        local task_name="${task_file##*/}"
        task_name="${task_name%.bash}"

        # Store the script path
        TASK_SCRIPTS["$task_name"]="$task_file"

        # Source the file in a subshell to extract DEPENDS array
        local deps
        deps=$(
            DEPENDS=()
            # TODO handle error when sourcing the recipes
            # shellcheck disable=SC1090
            source "$task_file" 2>/dev/null || true
            echo "${DEPENDS[*]}"
        )

        # Store dependencies
        TASK_DEPENDENCIES["$task_name"]="$deps"

        echo "  Found task: $task_name (dependencies: ${deps:-none})"
    done

    echo ""
}

# Check if all dependencies of a task are completed
function ec_dependencies_satisfied {
    local task=$1
    local deps="${TASK_DEPENDENCIES[$task]}"

    # No dependencies means ready to run
    [[ -z "$deps" ]] && return 0

    # Check each dependency
    for dep in $deps; do
        if [[ ! -v TASK_COMPLETED[$dep] ]]; then
            return 1 # Dependency not completed
        fi
    done

    return 0 # All dependencies completed
}

# Execute a task in the background
function _ec_execute_task {
    local task=$1
    local script="${TASK_SCRIPTS[$task]}"

    (
        # Ignore interrupt signals so task continues even when parent is interrupted
        trap '' SIGINT

        # Source the task script and call do_install
        DEPENDS=()
        # shellcheck disable=SC1090
        source "$script"

        printf "[%(%Y-%m-%d %H:%M:%S)T] Starting: %s\n" -1 "$task"
        do_install
        sleep $(( (RANDOM % 5) + 1))
        printf "[%(%Y-%m-%d %H:%M:%S)T] Completed: %s\n" -1 "$task"
    ) &

    # Store the PID
    TASK_RUNNING["$task"]=$!
}

# Main execution loop with dynamic dependency resolution
function ec_execute_tasks {
    echo "Executing tasks..."
    echo ""

    local total_tasks=${#TASK_SCRIPTS[@]}
    local completed_count=0

    # Reverse mapping: PID -> task name
    declare -A pid_to_task=()

    while (( $completed_count < $total_tasks )); do
        # Start all tasks whose dependencies are satisfied
        local tasks_started=0
        for task in "${!TASK_SCRIPTS[@]}"; do
            # Skip if already completed or running
            [[ -v TASK_COMPLETED[$task] ]] && continue
            [[ -v TASK_RUNNING[$task] ]] && continue
            (( ${#TASK_RUNNING[@]} >= JOBS_COUNT )) && continue

            # Check if dependencies are satisfied
            if ec_dependencies_satisfied "$task"; then
                _ec_execute_task "$task"
                pid_to_task["${TASK_RUNNING[$task]}"]="$task"
                tasks_started=1
            fi
        done

        # If no tasks are running and none could start, we have a problem
        local running_count=${#TASK_RUNNING[@]}
        if (( running_count == 0 )); then
            if (( tasks_started == 0 )); then
                echo "ERROR: No tasks can be started. Possible circular dependency!" >&2
                echo "Blocked tasks (unmet dependencies):" >&2
                for task in "${!TASK_SCRIPTS[@]}"; do
                    if [[ ! -v TASK_COMPLETED[$task] ]]; then
                        echo "  - $task (depends on: ${TASK_DEPENDENCIES[$task]:-none})" >&2
                    fi
                done
                exit 1
            fi
            continue
        fi

        # Wait for any single task to complete
        local completed_pid
        if wait -n -p completed_pid; then
            # Find which task completed
            if [[ -v pid_to_task[$completed_pid] ]]; then
                local completed_task="${pid_to_task[$completed_pid]}"
                TASK_COMPLETED["$completed_task"]=1
                unset "TASK_RUNNING[$completed_task]"
                unset "pid_to_task[$completed_pid]"
                completed_count=$((completed_count + 1))
            fi
        else
            # A task failed
            local failed_task="${pid_to_task[$completed_pid]:-unknown}"
            echo "ERROR: Task '$failed_task' (PID: $completed_pid) failed!" >&2
            exit 1
        fi

        # Loop continues immediately to check for newly ready tasks
    done

    echo ""
    echo "All tasks completed successfully!"
}

# Validate that all dependencies exist
function ec_validate_dependencies {
    local validation_failed=0

    for task in "${!TASK_DEPENDENCIES[@]}"; do
        local deps="${TASK_DEPENDENCIES[$task]}"

        for dep in $deps; do
            if [[ ! -v TASK_SCRIPTS[$dep] ]]; then
                echo "ERROR: Task '$task' depends on '$dep', but '$dep' does not exist!" >&2
                validation_failed=1
            fi
        done
    done

    if (( validation_failed == 1 )); then
        exit 1
    fi
}

# Main execution
function main {
    # Directory containing all task files
    local tasks_dir="${1:-./layer-core/recipes}"

    if [[ ! -d "$tasks_dir" ]]; then
        echo "ERROR: Tasks directory '$tasks_dir' not found!" >&2
        exit 1
    fi

    ec_discover_tasks "$tasks_dir"

    if (( ${#TASK_SCRIPTS[@]} == 0 )); then
        echo "No tasks found in '$tasks_dir'!"
        exit 0
    fi

    ec_validate_dependencies
    ec_execute_tasks
}

main "$@"
