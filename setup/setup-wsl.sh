
function setup-common ()
{
  git clone git@github.com:DragonCrafted87/bash-settings.git
  rm .bashrc
  rm .bashrc.d
  ln -s /home/dragon/bash-settings/wsl_bashrc.sh .bashrc
  ln -s /home/dragon/bash-settings/bashrc.d/ .bashrc.d

  sudo sh -c 'echo "dragon ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers'
  sudo rm /root/.bashrc
  sudo ln -s /home/dragon/.bashrc /root/.bashrc
  sudo ln -s /home/dragon/.bashrc.d/ /root/.bashrc.d
}
