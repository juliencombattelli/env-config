#!/bin/bash

PROXY_SERV="@EC_PROXY_SERVER@"
PROXY_PORT="@EC_PROXY_PORT@"
PROXY_USER="@EC_PROXY_USER@"
PROXY_PASS="@EC_PROXY_PASSWORD@"

if [ -z "$PROXY_SERV" ]; then
    # No proxy server defined, nothing to do
    return
fi

function get_url() {
    local COMP_SERV="$PROXY_SERV"
    if [ -n "$PROXY_PORT" ]; then
        local COMP_PORT=":$PROXY_PORT"
    fi
    if [ -n "$PROXY_USER" ]; then
        local COMP_USER="$PROXY_USER"
        # Use password only if user is defined
        if [ -n "$PROXY_PASS" ]; then
            local COMP_PASS=":$PROXY_PASS"
        fi
        local COMP_AUTH="$COMP_USER$COMP_PASS@"
    fi
    echo "http://$COMP_AUTH$COMP_SERV$COMP_PORT"
}

PROXY_URL="$(get_url)"

function proxy_reachable() {
    if ping -c 1 $PROXY_SERV &>/dev/null; then return 0; else return 1; fi
}

if proxy_reachable; then
    alias sudo="sudo -E " # Enable evaluation of user-defined aliases even on sudoed commands
    alias apt="apt -o=\"Acquire::http::proxy=$PROXY_URL\" -o=\"Acquire::https::proxy=$PROXY_URL\""
    export {http,https,ftp,rsync}_proxy=$PROXY_URL
    export {HTTP,HTTPS,FTP,RSYNC}_PROXY=$PROXY_URL
    export no_proxy="localhost,127.0.0.1,.local" # TODO use EC_NO_PROXY
fi
