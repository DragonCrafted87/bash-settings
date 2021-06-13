#!/bin/bash

case "$OSTYPE" in
    linux*)
        echo 'Linux'
    ;;

    win*|msys*|cygwin*)
        echo 'MS Windows'
        export CMAKE_C_COMPILER='C:\ProgramData\chocolatey\lib\winlibs\tools\mingw64\bin\clang.exe'
        export CMAKE_CXX_COMPILER='C:\ProgramData\chocolatey\lib\winlibs\tools\mingw64\bin\clang++.exe'

    ;;

    *)
        echo 'unknown: $OSTYPE'
    ;;
esac
