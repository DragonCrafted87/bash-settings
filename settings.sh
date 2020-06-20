#!/bin/bash

HISTCONTROL=ignoredups:ignorespace:erasedups
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s checkwinsize

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

export FORMAT="\nID\t{{.ID}}\nIMAGE\t{{.Image}}\nCOMMAND\t{{.Command}}\nCREATED\t{{.RunningFor}}\nSTATUS\t{{.Status}}\nPORTS\t{{.Ports}}\nNAMES\t{{.Names}}\n"


# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

typeset +x PS1="${DARK_YELLOW}\u${NC}@${DARK_YELLOW}${HOSTNAME}${NC}:${CYAN}\w${NC}\n> "

export GOPATH=$HOME/go

PATH=/home/dragon/bin:$PATH
PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
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

if [ -e ./aliases.sh ]; then
    . ./aliases.sh
fi

for f in ./functions/*; do source $f; done

function run-once-per-boot ()
{
  if [ ! -f /tmp/dragon_has_logged_in ]; then
    wsl-fix-drive-mounts
    touch /tmp/dragon_has_logged_in
  fi
}
