DESCRIPTION = ""
PN = "oh-my-posh"
PV = "1"

DEPENDS += "powershell"

inherit installable

SRC_URI += "file://p10k.omp.json"

do_install() {
    # The same command is executed in both cases, but it is nice to know if it
    # is already installed or if it is a fresh install
    if powershell.exe -Command "Get-Command oh-my-posh"; then
        bbplain "oh-my-posh already installed. Updating."
        winget.exe install JanDeDobbeleer.OhMyPosh -s winget
    else
        bbplain "Installing oh-my-posh."
        winget.exe install JanDeDobbeleer.OhMyPosh -s winget
    fi
}

do_configure() {
    # TODO move into wsl platform inc file to be available globally
    WINDOWS_USERPROFILE="$(wslpath -u $(powershell -Command '$Env:USERPROFILE'))"
    WINDOWS_POWERSHELL5_PROFILE="$(wslpath -u $(powershell -Command '$PROFILE'))"
    WINDOWS_PWSH_PROFILE="$(/mnt/c/Windows/System32/cmd.exe /c 'pwsh -Command $PROFILE')"

    mkdir -p "${WINDOWS_USERPROFILE}.env-config/share/oh-my-posh/themes/"
    cp "${WORKDIR}"/p10k.omp.json "${WINDOWS_USERPROFILE}"/etc/profile.d/
    $WINDOWS_PROFILE

}
