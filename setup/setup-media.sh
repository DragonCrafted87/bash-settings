#!/bin/bash

return
sudo apt install git curl ssh

#ssh keys
curl -0 https://github.com/dragoncrafted87.keys > .ssh/authorized_keys

# Only allow key based logins
cd /tmp
sed -n 'H;${x;s/\#PasswordAuthentication yes/PasswordAuthentication no/;p;}' /etc/ssh/sshd_config > tmp_sshd_config
sed -n 'H;${x;s/\PasswordAuthentication yes/PasswordAuthentication no/;p;}' tmp_sshd_config > tmp_sshd_config
sudo mv tmp_sshd_config /etc/ssh/sshd_config

sudo hostnamectl set-hostname medialivingroom.lan


sudo apt install software-properties-common
sudo add-apt-repository -ysP team-xbmc/ppa
sudo apt install kodi

sudo apt install kodi-visualization-goom
sudo apt install kodi-visualization-projectm
sudo apt install kodi-visualization-shadertoy
sudo apt install kodi-visualization-spectrum
sudo apt install kodi-visualization-waveform
sudo apt install xbmc-visualization-fishbmc

