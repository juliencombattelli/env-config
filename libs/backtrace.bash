#!/usr/bin/env bash

# Inspired by https://github.com/bahamas10/bash-stacktrace

function backtrace {
    # read arguments
    local whencolor='auto'
    local OPTIND OPTARG opt
    while getopts 'C:v' opt; do
        case "$opt" in
            C) whencolor=$OPTARG;;
            *) return 1;;
        esac
    done
    shift "$((OPTIND - 1))"

    # optionally load colors
    if [[ $whencolor == always ]] || [[ $whencolor == auto && -t 1 ]]; then
        local color_cyan=$'\e[36m'
        local color_bold=$'\e[1m'
        local color_rst=$'\e[0m'
    else
        local color_cyan=''
        local color_rst=''
    fi

    local i=0
    local file func line

    echo 'Backtrace:'
	local -r frame_count="$(( ${#BASH_SOURCE[@]} - 2 ))"
	local -r frame_count_len="${#frame_count}"
    while true; do
        file=${BASH_SOURCE[i+1]:-}
        func=${FUNCNAME[i]}
        line=${BASH_LINENO[i]}
        [[ -n $file ]] || break

        printf '  #%0*d in %s%s%s %s(%s:%s)%s\n' \
            "$frame_count_len" "$i" \
            "$color_bold" "$func" "$color_rst" \
            "$color_cyan" "$file" "$line" "$color_rst"

        ((i+=1))
    done
}
