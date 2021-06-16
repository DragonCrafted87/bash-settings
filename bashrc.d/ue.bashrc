#!/bin/bash

function ue-update-project-file ()
{
  saved_dir=$PWD
  cd ~/repos
  sed '/FilesU/q' server.prj > /tmp/server.prj

  i=0
  prefix='=.+AFw-'
  suffix='+AFw-'
  for d in */ ; do
    echo "$i$prefix$d$suffix" >> /tmp/server.prj
    ((i++))
  done
  mv /tmp/server.prj .
  cd $saved_dir
}