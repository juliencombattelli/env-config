FEDORA_ATOMIC=false
if cat /proc/mounts | grep " / " | cut -d' ' -f4 | grep -E "(^|,)ro(,|$)" &>/dev/null; then
    FEDORA_ATOMIC=true
fi

EC_DISTRO_PKG_PROVIDERS+=(pip)
if ! $FEDORA_ATOMIC; then
    EC_DISTRO_PKG_PROVIDERS+=(dnf)
fi
