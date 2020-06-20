
export WSL=true

sudo run-parts /etc/update-motd.d

if [ -d /mnt/d/repos/bash-settings ]; then
  SAVE_DIR=$PWD
  cd /mnt/d/repos/bash-settings
  if [ -f ./settings.sh ]; then
    . ./settings.sh
  fi
  cd $SAVE_DIR
fi
