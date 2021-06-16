#!/bin/bash

WSL=true
export WSL

sudo run-parts /etc/update-motd.d

for file in ~/.bashrc.d/*.bashrc;
do
    # shellcheck disable=SC1090
    source "$file"
done

function update-bash-settings ()
{
    cp -r ~/repos/bash-settings/* ~/bash-settings/
    # shellcheck disable=SC1090
    source ~/.bashrc
}

function run-once-per-boot ()
{
    if [ ! -f /tmp/dragon_has_logged_in ]; then
        wsl-fix-drive-mounts
        sudo apt update
        apt list --upgradable
        touch /tmp/dragon_has_logged_in
    fi
}

if [ ! -f /tmp/dragon_has_logged_in ]; then
    run-once-per-boot
fi
