#!/bin/bash

for file in ~/.bashrc.d/*.bashrc;
do
    # shellcheck disable=SC1090
    source "$file"
done

if ! pgrep -x "x11vnc" > /dev/null
then
    x11vnc -forever -loop -noxdamage -repeat -rfbport 5900 -shared --display :0 &
fi
