
return

function setup-common ()
{
  ssh-keygen -t ecdsa -b 521

  git clone git@github.com:DragonCrafted87/bash-settings.git
  rm .bashrc
  rm .bashrc.d
  ln -s /home/dragon/bash-settings/hw_bashrc.sh .bashrc
  ln -s /home/dragon/bash-settings/bashrc.d/ .bashrc.d

  sudo sh -c 'echo "dragon ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers'
  sudo rm /root/.bashrc
  sudo ln -s /home/dragon/.bashrc /root/.bashrc
  sudo ln -s /home/dragon/.bashrc.d/ /root/.bashrc.d
  sudo timedatectl set-timezone America/Chicago
  sudo ln -s /usr/bin/python3 /usr/bin/python

  sudo apt autoremove --purge snapd
  sudo apt autoremove --purge kubeadm  kubectl  kubelet
  sudo apt autoremove --purge docker-ce docker-ce-cli containerd.io

  #add to root crontab
  # @reboot sudo swapoff -a
  # also remove entry in /etc/fstab

  #edit
  sudo nano /etc/update-manager/release-upgrades
}
