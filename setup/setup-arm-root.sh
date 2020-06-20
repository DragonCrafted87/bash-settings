
# curl -0 https://github.com/dragoncrafted87.keys > authorized_keys


# exec sudo -i
function replace-user ()
{
  killall -u $1
  id $1
  usermod -l $2 $1
  groupmod -n $2 $1
  usermod -d /home/$2 -m $2
  usermod -c $3 $2
  id $2
}
# replace-user ubuntu dragon 'Scott Gudeman'
