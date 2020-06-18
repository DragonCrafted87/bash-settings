#!/bin/bash

function wsl-install-apps ()
{
  sudo apt install curl
  sudo apt install kubectl
  sudo apt install ansible
}

function wsl-fix-drive-mounts ()
{
  cd ~
  sudo umount /mnt/c
  sudo umount /mnt/d

  sudo mount -t drvfs C: /mnt/c -o metadata,uid=1000,gid=1000,umask=22,fmask=111
  sudo mount -t drvfs D: /mnt/d -o metadata,uid=1000,gid=1000,umask=22,fmask=111
}
