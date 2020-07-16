
function setup-common ()
{
  git clone git@github.com:DragonCrafted87/bash-settings.git
  rm -rf .bashrc
  rm -rf .bashrc.d
  ln -s /home/dragon/bash-settings/wsl_bashrc.sh .bashrc
  ln -s /home/dragon/bash-settings/bashrc.d/ .bashrc.d

  sudo sh -c 'echo "dragon ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers'
  sudo rm /root/.bashrc
  sudo ln -s /home/dragon/.bashrc /root/.bashrc
  sudo ln -s /home/dragon/.bashrc.d/ /root/.bashrc.d

  sudo apt install cifs-utils
#
#  # Helm Install
#  curl https://helm.baltorepo.com/organization/signing.asc | sudo apt-key add -
#  sudo apt-get install apt-transport-https --yes
#  echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
#  sudo apt-get update
#  sudo apt-get install helm
#


}
