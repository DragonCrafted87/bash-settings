#!/bin/bash
export GIT_BASH=true

for file in "$HOME"/bash-settings/bashrc.d/*.bashrc;
do
    # shellcheck disable=SC1090
    source "$file"
done

eval "$(oh-my-posh init bash --config ~/bash-settings/omp.yaml)"
