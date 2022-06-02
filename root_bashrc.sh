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

# shellcheck disable=SC2086
eval "$(oh-my-posh init bash --config /home/$BASH_SETTING_USERNAME/bash-settings/omp.yaml)"
