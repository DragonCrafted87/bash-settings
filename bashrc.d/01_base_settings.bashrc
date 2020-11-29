#!/bin/bash

HISTCONTROL='ignoredups:ignorespace:erasedups'
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize
shopt -s histappend

WHITE='\033[1;37m'
BLACK='\033[0;30m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DARK_GRAY='\033[1;30m'
DARK_YELLOW='\033[0;33m'
GREEN='\033[0;32m'
LIGHT_BLUE='\033[1;34m'
LIGHT_CYAN='\033[1;36m'
LIGHT_GRAY='\033[0;37m'
LIGHT_GREEN='\033[1;32m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_RED='\033[1;31m'
LIGHT_YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

export VISUAL=nano
export EDITOR="$VISUAL"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


export GOPATH=$HOME/go

BASE_PATH=$PATH

PATH=/home/dragon/bin
PATH=$PATH:/home/dragon/.local/bin
PATH=$PATH:/home/dragon/scripts
PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
PATH=$PATH:$HOME/bash-settings/scripts
PATH=$PATH:$BASE_PATH
export PATH

export KUBECONFIG=~/.kube/config

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
