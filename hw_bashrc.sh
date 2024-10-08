#!/bin/bash

# shellcheck disable=SC1091
source /etc/profile

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

eval "$(oh-my-posh init bash --config ~/bash-settings/omp.yaml)"
