set -euo pipefail

bg_tasks_pid=()

function kill_background_processes {
    kill "${bg_tasks_pid[@]}" 2>/dev/null || true
}

function wait_background_processes {
    local silent="${1:-}"
    local remaining=${#bg_tasks_pid[@]}
    while [[ $remaining -gt 0 ]]; do
        if [[ "$silent" != "silent" ]]; then
            echo "Waiting for $remaining background process(es) to complete..." 
        fi
        wait -n 2>/dev/null || true
        remaining=$((remaining - 1))
    done
}

function reset_terminal {
    echo "Resetting terminal"
}

function at_exit {
    echo "[EXIT] at_exit"
    
    reset_terminal
}

function on_interrupt {
    sigint_code=$?
    echo ""
    echo "[SIGINT] on_interrupt"

    if [[ "${ON_INTERRUPT:-0}" == 1 ]]; then
        echo "[SIGINT] Second interrupt, aborting."
        kill_background_processes
    else
        echo "[SIGINT] First interrupt, waiting."
        ON_INTERRUPT=1
        wait_background_processes
    fi

    exit $sigint_code
}

trap on_interrupt SIGINT
trap at_exit EXIT

function spawn_task {
    (
        local id="$1"
        local sleep_duration=$(( (RANDOM % 10) + 1 ))
        trap '' SIGINT

        echo "[SUB $id] Sleeping..."
        sleep $sleep_duration
        echo "[SUB $id] Done sleeping!"
    ) &
    bg_tasks_pid+=($!)
}

task_id=0
for _ in {1..5}; do
    spawn_task $((++task_id))
done

wait_background_processes silent
