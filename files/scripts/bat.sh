if command -v bat >/dev/null 2>&1; then
    export BAT_THEME="VSCodeDarkModern"
    export MANPAGER="sh -c 'col -bx | bat -plman --strip-ansi=always'"
fi
