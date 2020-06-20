#!/bin/bash

return

git clone --single-branch --branch alpine https://github.com/ilpianista/pi-hole.git

ssh-keygen -t ecdsa -b 521

git clone git@github.com:DragonCrafted87/bash-settings.git
rm .bashrc
rm .bashrc.d
ln -s /home/dragon/bash-settings/hw_bashrc.sh .bashrc
ln -s /home/dragon/bash-settings/bashrc.d/ .bashrc.d

git clone git@github.com:DragonCrafted87/bash-settings.git
rm .bashrc
rm .bashrc.d
ln -s /home/dragon/bash-settings/wsl_bashrc.sh .bashrc
ln -s /home/dragon/bash-settings/bashrc.d/ .bashrc.d
