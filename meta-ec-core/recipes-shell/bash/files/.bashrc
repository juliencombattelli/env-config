
# Source any .sh and .bash script in @EC_TARGET_INSTALL_DIR@/etc/profile.d
for f in @EC_TARGET_INSTALL_DIR@/etc/profile.d/*; do
    if [[ "$f" =~ ^.*\.(ba)?sh$ ]]; then
        source "$f"
    fi
done
