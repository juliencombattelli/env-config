#!/bin/sh

if [ "$(which-platform)" = "wsl2" ] && findmnt /mnt/wslg/ 2>&1 >/dev/null ; then
    # WSLg enabled on WSL2, X11 forwarding already configured
    return
fi

export DISPLAY=@X11_DISPLAY@
export LIBGL_ALWAYS_INDIRECT=1
