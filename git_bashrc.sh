#!/bin/bash
export GIT=true



for file in $HOME/bash-settings/bashrc.d/*.bashrc;
do
source "$file"
done
