#!/bin/bash

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
        mingw-w64-clang-x86_64-rust \
        mingw-w64-clang-x86_64-toolchain

    /clang64/bin/pip.exe install wheel
    /clang64/bin/pip.exe install requests python-dateutil
}
