#!/bin/bash

case "$OSTYPE" in
    win*|msys*|cygwin*)
        ;;
    *)
        return
        ;;
esac

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
