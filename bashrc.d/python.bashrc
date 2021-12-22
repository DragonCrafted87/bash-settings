#!/bin/bash

alias pylint=pylint_runner
alias pre-commit-check='pre-commit run --all-files'
alias pre-commit-update='pre-commit autoupdate'

case "$OSTYPE" in
    win*|msys*)
        alias pip='python -m pip'
        ;;

    *)
        ;;
esac
