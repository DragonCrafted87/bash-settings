#!/bin/bash

case "$OSTYPE" in
    linux*)
        [[ -t 1 ]] && echo "Linux"
        ;;

    win*|msys*|cygwin*)
        [[ -t 1 ]] && echo "MS Windows"
        BASE_PATH=$PATH
        PATH=$PATH:$BASE_PATH
        PATH="$PATH:/c/Program Files/Docker/Docker/resources/bin/"
        PATH="$PATH:/c/Program Files/LLVM/bin"
        export PATH
        ;;
    *)
        [[ -t 1 ]] && echo "unknown: $OSTYPE"
        ;;
esac
