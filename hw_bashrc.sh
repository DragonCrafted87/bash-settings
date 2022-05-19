#!/bin/bash

for file in ~/.bashrc.d/*.bashrc;
do
    # shellcheck disable=SC1090
    source "$file"
done

function update-bash-settings ()
{
    saved_working_dir="$PWD"
    cd ~/bash-settings || return
    git pull
    # shellcheck disable=SC1090
    source ~/.bashrc
    cd "$saved_working_dir" || return
}

eval "$(oh-my-posh init bash --config /home/dragon/bash-settings/omp.yaml)"
