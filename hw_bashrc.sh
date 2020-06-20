if [ -d bash-settings ]; then
  SAVE_DIR=$PWD
  cd bash-settings
  if [ -f ./settings.sh ]; then
    . ./settings.sh
  fi
  cd $SAVE_DIR
fi
