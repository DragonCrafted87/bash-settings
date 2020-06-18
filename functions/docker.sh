#!/bin/bash

function docker-build ()
{
  docker build \
  --no-cache \
  --pull \
  --file Dockerfile \
  --tag $1 \
  .
}
