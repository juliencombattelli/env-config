# Associative arrays to store task information
declare -A EC_TASK_DEPENDENCIES=() # task -> space-separated list of dependencies
declare -A EC_TASK_RECIPES=()      # task -> path to task script
declare -A EC_TASK_COMPLETED=()    # task -> exit status (0 on success, non-zero on failure)
declare -A EC_TASK_RUNNING=()      # task -> PID if running
declare -A EC_TASK_TIMER=()        # task -> duration time points

function ec_get_recipe_file_for_package {
    local package="$1"
    local -a recipe_file=()
    recipe_file+=(recipes/"$package".bash)
    if (( ${#recipe_file[@]} > 1 )); then
        ec_log E "Found more than one recipe for package \`$package\` (total ${#recipe_file[@]}):"
        ec_log E "${recipe_file[@]}"
        return 1
    elif (( ${#recipe_file[@]} == 0 )); then
        ec_log E "No recipe found for package \`$package\`."
        return 1
    fi
    echo "${recipe_file[@]}"
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
    task_file="$(ec_get_recipe_file_for_package "$task_name")" || return 1

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
    local package
    for package in "${target_packages[@]}"; do
        ec_discover_task "$package" || continue
    done
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
