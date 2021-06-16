#!/bin/bash

alias pylint=pylint_runner

case "$OSTYPE" in
    win*|msys*)
        alias pip='python -m pip'
        ;;

    *)
        ;;
esac
