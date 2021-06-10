
return


git clone https://github.com/DragonCrafted87/bash-settings.git
rm .bashrc
rm .bashrc.d
ln -s /home/dragon/bash-settings/hw_bashrc.sh .bashrc
ln -s /home/dragon/bash-settings/bashrc.d/ .bashrc.d

sudo sh -c 'echo "dragon ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/sudoers'
sudo rm /root/.bashrc
sudo ln -s /home/dragon/.bashrc /root/.bashrc
sudo ln -s /home/dragon/.bashrc.d/ /root/.bashrc.d
sudo timedatectl set-timezone America/Chicago
sudo ln -s /usr/bin/python3 /usr/bin/python

sudo apt autoremove --purge kubeadm  kubectl  kubelet
sudo apt autoremove --purge docker-ce docker-ce-cli containerd.io

#add to root crontab
sudo crontab -e
# @reboot sudo swapoff -a
# also remove entry in /etc/fstab
sudo nano /etc/fstab

sudo apt update
sudo apt dist-upgrade

# do hw specific setup

sudo apt install nfs-common cifs-utils
sudo apt install cifs-utils


#install microk8s
sudo snap install microk8s --classic --channel=1.19/stable

#from an active node run then execute the join command
microk8s add-node

