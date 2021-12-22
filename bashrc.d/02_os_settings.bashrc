#!/bin/bash

case "$OSTYPE" in
    linux*)
        [[ -t 1 ]] && echo "Linux"
        ;;

    win*|msys*|cygwin*)
        [[ -t 1 ]] && echo "MS Windows"
        ;;
    *)
        [[ -t 1 ]] && echo "unknown: $OSTYPE"
        ;;
esac
