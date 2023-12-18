#!/bin/bash

case "$OSTYPE" in
    win*|msys*|cygwin*)
        ;;
    *)
        return
        ;;
esac
USER=$(whoami)

WINGET_PACKAGE_LIST=( \
        "7zip.7zip" \
        "BellSoft.LibericaJDK.17.Full" \
        "BraveSoftware.BraveBrowser" \
        "Discord.Discord" \
        "Docker.DockerDesktop" \
        "EpicGames.EpicGamesLauncher" \
        "Facebook.Messenger" \
        "File-New-Project.EarTrumpet" \
        "Foxit.FoxitReader" \
        "GIMP.GIMP" \
        "Git.Git" \
        "GOG.Galaxy" \
        "GuinpinSoft.MakeMKV" \
        "Inkscape.Inkscape" \
        "JAMSoftware.TreeSize.Free" \
        "JFrog.Conan" \
        "KDE.Kdenlive" \
        "Kitware.CMake" \
        "Klocman.BulkCrapUninstaller" \
        "Logitech.GHUB" \
        "Microsoft.VisualStudioCode" \
        "Microsoft.WindowsTerminal" \
        "OBSProject.OBSStudio" \
        "OpenJS.NodeJS.LTS" \
        "Python.Python.3.11" \
        "TeamViewer.TeamViewer" \
        "Twilio.Authy" \
        "Valve.Steam" \
    )

WINGET_INSTALL_LIST=( \
    )

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

function winget-upgrade-packages ()
{
    for i in "${WINGET_PACKAGE_LIST[@]}"
    do
        winget upgrade "$i" -e --source winget
    done
}

function winget-install-packages ()
{
    for i in "${WINGET_INSTALL_LIST[@]}"
    do
        winget install "$i" -e --source winget
    done
}
