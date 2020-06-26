#!/bin/bash

if [ -z $WSL ] ; then
  return
fi

function wsl-install-apps ()
{
  sudo apt install curl
  sudo apt install kubectl
  sudo apt install ansible
}

function wsl-fix-drive-mounts ()
{
  if [ -z /home/dragon/repos ] ; then
    mkdir /home/dragon/repos
  fi

  sudo umount /mnt/c 2>/dev/null
  sudo umount /mnt/d 2>/dev/null
  sudo umount /home/dragon/repos 2>/dev/null

  sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000,umask=22,fmask=111
  sudo mount -t drvfs D: /mnt/d -o metadata,uid=1000,gid=1000,umask=22,fmask=111
  sudo mount -t drvfs R: /home/dragon/repos -o metadata,uid=1000,gid=1000,umask=22,fmask=111
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
