#!/bin/bash

if [ -z $WSL ] ; then
  return
fi

function wsl-install-apps ()
{
  sudo apt install -y \
    cifs-utils \
    curl \
    kubectl
}

function wsl-fix-drive-mounts ()
{
  if [ -z /home/dragon/repos ] ; then
    mkdir /home/dragon/repos
  fi

  sudo umount /home/dragon/repos 2>/dev/null

  sudo mount.cifs //dragondata.lan/Storage/Programming/git-repos /home/dragon/repos -o vers=3.0,credentials=/home/dragon/.smb_credentials,iocharset=utf8,file_mode=0777,dir_mode=0777

}

function wsl-fix-tmp ()
{
  sudo rm -r /tmp/*
  sudo sh -c 'echo "tmpfs /tmp tmpfs nosuid,nodev,noatime 0 0" >> /etc/fstab'
  sudo mount -a
}

function wsl-update-kubectl-config ()
{
  mkdir -p /home/dragon/.kube
  scp dragonmaster.lan:/home/dragon/.kube/config /home/dragon/.kube/config
  cp /home/dragon/.kube/config /mnt/c/Users/gudem/.kube
}
