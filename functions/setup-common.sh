
function setup-common ()
{
  sudo sh -c 'echo "dragon ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers'
  sudo rm /root/.bashrc
  sudo ln -s /home/dragon/.bashrc /root/.bashrc
}
