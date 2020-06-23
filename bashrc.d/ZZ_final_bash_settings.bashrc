#!/bin/bash

function run-once-per-boot ()
{
  if [ ! -f /tmp/dragon_has_logged_in ]; then
    sleep 5
    if [ "$WSL" = true ] ; then
      wsl-fix-drive-mounts
    fi
    touch /tmp/dragon_has_logged_in
  fi
}

if [ ! -f /tmp/dragon_has_logged_in ]; then
  run-once-per-boot &
fi