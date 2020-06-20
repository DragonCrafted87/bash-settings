
# curl -0 https://github.com/dragoncrafted87.keys > .ssh/authorized_keys

function set-ssh-key-only ()
{
  # Only allow key based logins
  cd /tmp
  sed -n 'H;${x;s/\#PasswordAuthentication yes/PasswordAuthentication no/;p;}' /etc/ssh/sshd_config > tmp_sshd_config
  sed -n 'H;${x;s/\PasswordAuthentication yes/PasswordAuthentication no/;p;}' tmp_sshd_config > tmp_sshd_config
  sudo mv tmp_sshd_config /etc/ssh/sshd_config
}

function set-host-name ()
{
  sudo hostnamectl set-hostname $1
}
