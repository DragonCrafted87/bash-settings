#!/bin/bash

GIT_BASH=true
export GIT_BASH

for file in "$HOME"/bash-settings/bashrc.d/*.bashrc;
do
    # shellcheck disable=SC1090
    source "$file"
done
