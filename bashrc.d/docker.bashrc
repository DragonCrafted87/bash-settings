#!/bin/bash

export FORMAT="\nID\t{{.ID}}\nIMAGE\t{{.Image}}\nCOMMAND\t{{.Command}}\nCREATED\t{{.RunningFor}}\nSTATUS\t{{.Status}}\nPORTS\t{{.Ports}}\nNAMES\t{{.Names}}\n"

function docker-build ()
{
  docker build \
  --no-cache \
  --pull \
  --file Dockerfile \
  --tag $1 \
  .
}

function docker-remove-all-images ()
{
  #delete containers
  docker rm -f $(docker ps -a -q)

  #delete images
  docker rmi -f $(docker images -q)
}
