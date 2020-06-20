
function wsl-install-apps ()
{
  sudo apt install curl
  sudo apt install kubectl
  sudo apt install ansible
}

function wsl-fix-drive-mounts ()
{
  rm /home/dragon/repos
  mkdir /home/dragon/repos
  sudo umount /mnt/c
  sudo umount /mnt/d

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
