#!/bin/bash
export GIT_BASH=true

for file in $HOME/bash-settings/bashrc.d/*.bashrc;
do
source "$file"
done
