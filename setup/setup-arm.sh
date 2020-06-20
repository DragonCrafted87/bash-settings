
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




sudo apt-get update
# Install SBC utility packages
sudo apt install -y nfs-common less vim ack git build-essential iptables ipset pciutils lshw file iperf3 net-tools lsb-release
# Fix ping permission
sudo chmod +s /bin/ping*
# Install Docker pre-requisites
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=arm64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system








