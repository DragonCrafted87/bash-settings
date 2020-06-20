
function install-ansible ()
{
  saved_working_directory=$PWD
  cd $HOME
  ansible-galaxy install geerlingguy.swap


  cd $saved_working_directory
}
