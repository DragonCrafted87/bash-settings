#!/bin/bash

case "$OSTYPE" in
    win*|msys*|cygwin*)
        ;;
    *)
        return
        ;;
esac
USER=$(whoami)

function msys-shutdown ()
{
    taskkill.exe //f //FI "MODULES eq msys-2.0.dll"
}

function windows-clear-icon-cache ()
{
    saved_dir=$PWD
    taskkill.exe //f //im explorer.exe
    cd /c/Users/gudem/AppData/Local/Microsoft/Windows/Explorer/ || return
    rm iconcache_*
    start explorer
    cd "$saved_dir" || return
}

function windows-clear-thumbnail-cache ()
{
    saved_dir=$PWD
    taskkill.exe //f //im explorer.exe
    cd /c/Users/gudem/AppData/Local/Microsoft/Windows/Explorer/ || return
    rm thumbcache_*
    start explorer
    cd "$saved_dir" || return
}

WINGET_PACKAGE_LIST=( \
        "BraveSoftware.BraveBrowser" \
        "Discord.Discord" \
        "Docker.DockerDesktop" \
        "Git.Git" \
        "LLVM.LLVM" \
        "Logitech.GHUB" \
        "Microsoft.VisualStudioCode" \
        "Microsoft.WindowsTerminal" \
        "Python.Python.3" \
        "Twilio.Authy" \
    )

function winget-install-packages ()
{
    for i in "${WINGET_PACKAGE_LIST[@]}"
    do
        winget install "$i" -e --source winget
    done
}
