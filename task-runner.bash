#!/usr/bin/env bash

set -euo pipefail

# Directory containing all task files
TASKS_DIR="${1:-./layer-core/recipes}"

# Associative arrays to store task information
declare -A task_dependencies=() # task -> space-separated list of dependencies
declare -A task_scripts=()      # task -> path to task script
declare -A task_completed=()    # task -> 1 if completed
declare -A task_running=()      # task -> PID if running

JOBS_COUNT=4

CLEANUP_DONE=0

function cleanup_background_processes {
    if [[ $CLEANUP_DONE == 1 ]]; then
        return
    fi
    CLEANUP_DONE=1

    trap 'kill_on_interrupt' SIGINT

    local -ar running_pids=("${!task_running[@]}")
    local remaining=${#running_pids[@]}

    while [[ $remaining -gt 0 ]]; do
        echo "Waiting for $remaining background process(es) to complete..." >&2
        wait -n 2>/dev/null || true
        remaining=$((remaining - 1))
    done
}

function kill_background_processes {
    background_jobs=($(jobs -p))
    if [[ ${#background_jobs[@]} != 0 ]]; then
        echo "Killing all background jobs" >&2
        kill "${background_jobs[@]}" >&2
    fi
}

function cleanup_on_interrupt {
    interrupt_exit_code=$?
    echo "" >&2
    cleanup_background_processes
    exit $interrupt_exit_code
}

function kill_on_interrupt {
    interrupt_exit_code=$?
    echo "" >&2
    kill_background_processes
    exit $interrupt_exit_code
}

trap cleanup_on_interrupt SIGINT
trap cleanup_background_processes EXIT

# Function to discover all task files
function discover_tasks {
    echo "Discovering tasks..."

    while IFS= read -r -d '' task_file; do
        # Get task name from filename (remove .bash extension)
        local task_name
        task_name=$(basename "$task_file" .bash)

        # Store the script path
        task_scripts["$task_name"]="$task_file"

        # Source the file in a subshell to extract DEPENDS array
        local deps
        deps=$(
            DEPENDS=()
            # shellcheck disable=SC1090
            source "$task_file" 2>/dev/null || true
            echo "${DEPENDS[*]}"
        )

        # Store dependencies
        task_dependencies["$task_name"]="$deps"

        echo "  Found task: $task_name (dependencies: ${deps:-none})"
    done < <(find "$TASKS_DIR" -name "*.bash" -type f -print0)

    echo ""
}

# Check if all dependencies of a task are completed
function dependencies_satisfied {
    local task=$1
    local deps="${task_dependencies[$task]}"

    # No dependencies means ready to run
    [[ -z "$deps" ]] && return 0

    # Check each dependency
    for dep in $deps; do
        if [[ -z "${task_completed[$dep]:-}" ]]; then
            return 1 # Dependency not completed
        fi
    done

    return 0 # All dependencies completed
}

# Execute a task in the background
function execute_task {
    local task=$1
    local script="${task_scripts[$task]}"

    (
        # Ignore interrupt signals so task continues even when parent is interrupted
        trap '' SIGINT

        # Source the task script and call do_install
        DEPENDS=()
        # shellcheck disable=SC1090
        source "$script"

        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting: $task"
        do_install
        sleep $(( (RANDOM % 5) + 1))
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Completed: $task"
    ) &

    # Store the PID
    task_running["$task"]=$!
}

# Main execution loop with dynamic dependency resolution
function execute_tasks {
    echo "Executing tasks..."
    echo ""

    local total_tasks=${#task_scripts[@]}
    local completed_count=0

    # Reverse mapping: PID -> task name
    declare -A pid_to_task

    while [[ $completed_count -lt $total_tasks ]]; do
        # Start all tasks whose dependencies are satisfied
        local tasks_started=0
        for task in "${!task_scripts[@]}"; do
            # Skip if already completed or running
            [[ -n "${task_completed[$task]:-}" ]] && continue
            [[ -n "${task_running[$task]:-}" ]] && continue
            (( ${#task_running[@]} >= JOBS_COUNT )) && continue

            # Check if dependencies are satisfied
            if dependencies_satisfied "$task"; then
                execute_task "$task"
                pid_to_task["${task_running[$task]}"]="$task"
                tasks_started=1
            fi
        done

        # If no tasks are running and none could start, we have a problem
        local running_pids=("${!task_running[@]}")
        local running_count=${#running_pids[@]}
        if [[ $running_count -eq 0 ]]; then
            if [[ $tasks_started -eq 0 ]]; then
                echo "ERROR: No tasks can be started. Possible circular dependency!" >&2
                echo "Remaining tasks:" >&2
                for task in "${!task_scripts[@]}"; do
                    if [[ -z "${task_completed[$task]:-}" ]]; then
                        echo "  - $task (waiting for: ${task_dependencies[$task]})" >&2
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
            local completed_task="${pid_to_task[$completed_pid]:-}"
            if [[ -n "$completed_task" ]]; then
                task_completed["$completed_task"]=1
                unset "task_running[$completed_task]"
                unset "pid_to_task[$completed_pid]"
                completed_count=$((completed_count + 1))
            fi
        else
            # A task failed
            local failed_task="${pid_to_task[$completed_pid]:-unknown}"
            echo "ERROR: Task '$failed_task' (PID: ${completed_pid:-unknown}) failed!" >&2
            exit 1
        fi

        # Loop continues immediately to check for newly ready tasks
    done

    echo ""
    echo "All tasks completed successfully!"
}

# Validate that all dependencies exist
function validate_dependencies {
    local validation_failed=0

    for task in "${!task_dependencies[@]}"; do
        local deps="${task_dependencies[$task]}"

        for dep in $deps; do
            if [[ -z "${task_scripts[$dep]:-}" ]]; then
                echo "ERROR: Task '$task' depends on '$dep', but '$dep' does not exist!" >&2
                validation_failed=1
            fi
        done
    done

    if [[ $validation_failed -eq 1 ]]; then
        exit 1
    fi
}

# Main execution
function main {
    if [[ ! -d "$TASKS_DIR" ]]; then
        echo "ERROR: Tasks directory '$TASKS_DIR' not found!" >&2
        exit 1
    fi

    discover_tasks

    if [[ ${#task_scripts[@]} -eq 0 ]]; then
        echo "No tasks found in '$TASKS_DIR'!"
        exit 0
    fi

    validate_dependencies
    execute_tasks
}

main "$@"
