#!/bin/bash

alias pylint=pylint_runner

case "$OSTYPE" in
    win*|msys*)
        # alias python=/usr/bin/python.exe
        # alias pip='python -m pip'
        ;;

    *)
        ;;
esac

function python-setup ()
{
    python -m pip install --upgrade pip

    pip install wheel

    pip install \
        poetry \
        pre-commit \
        python-dateutil \
        requests
}
