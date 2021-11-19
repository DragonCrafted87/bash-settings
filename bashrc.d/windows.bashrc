#!/bin/bash

case "$OSTYPE" in
    win*|msys*|cygwin*)
        ;;
    *)
        return
        ;;
esac
USER=whoami

BASE_PATH=$PATH
PATH=$PATH:"/c/Program Files/cppcheck"
PATH=$PATH:/c/users/$USER/scoop/shims
PATH=$PATH:/c/users/$USER/scoop/apps/winlibs-mingw-llvm-ucrt/current/bin
PATH=$PATH:$BASE_PATH
export PATH

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
