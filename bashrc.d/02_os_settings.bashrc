#!/bin/bash

case "$OSTYPE" in
    linux*)
        [[ -t 1 ]] && echo 'Linux'
    ;;

    win*|msys*|cygwin*)
        [[ -t 1 ]] && echo 'MS Windows'
        export CMAKE_C_COMPILER='C:\ProgramData\chocolatey\lib\winlibs\tools\mingw64\bin\clang.exe'
        export CMAKE_CXX_COMPILER='C:\ProgramData\chocolatey\lib\winlibs\tools\mingw64\bin\clang++.exe'

    ;;

    *)
        [[ -t 1 ]] && echo 'unknown: $OSTYPE'
    ;;
esac
