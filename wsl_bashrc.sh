export WSL=true

sudo run-parts /etc/update-motd.d

for file in ~/.bashrc.d/*.bashrc;
do
source "$file"
done

function update-bash-settings ()
{
  cp -r ~/repos/bash-settings/* ~/bash-settings/
  source ~/.bashrc
}

function run-once-per-boot ()
{
  if [ ! -f /tmp/dragon_has_logged_in ]; then
    sleep 5
    wsl-fix-drive-mounts
    touch /tmp/dragon_has_logged_in
  fi
}

if [ ! -f /tmp/dragon_has_logged_in ]; then
  run-once-per-boot &
fi
