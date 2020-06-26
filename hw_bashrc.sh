for file in ~/.bashrc.d/*.bashrc;
do
source "$file"
done

function update-bash-settings ()
{
  saved_working_dir=$PWD
  cd ~/bash-settings
  git pull
  source ~/.bashrc
  cd $saved_working_dir
}
