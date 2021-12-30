#!/bin/bash

case "$OSTYPE" in
    win*|msys*|cygwin*)
        ;;
    *)
        return
        ;;
esac
USER=$(whoami)

export CC=/bin/clang
export CXX=/bin/clang++

alias python=/bin/python.exe

BASE_PATH=$PATH
PATH="/d/git-home/bin"
PATH=$PATH:$BASE_PATH
PATH="$PATH:/c/Program Files/nodejs"
PATH="$PATH:/c/Program Files/Docker/Docker/resources/bin/"
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

function msys-setup ()
{
    grep "^${USERNAME}:" /etc/passwd >/dev/null 2>&1 || mkpasswd | grep "^${USERNAME}:" >> /etc/passwd
    nano /etc/passwd
}


function msys-update ()
{
    pacman -Syuu
}

function msys-install-base-packages ()
{
    pacman -S \
        --needed \
        base-devel \
        python-pip \
        git \
        mingw-w64-clang-x86_64-boost\
        mingw-w64-clang-x86_64-cmake \
        mingw-w64-clang-x86_64-cppcheck \
        mingw-w64-clang-x86_64-ffmpeg \
        mingw-w64-clang-x86_64-ninja \
        mingw-w64-clang-x86_64-python-pip \
        mingw-w64-clang-x86_64-toolchain
}
