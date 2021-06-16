#!/bin/bash

function color_my_prompt {
    local __user_and_host="${DARK_YELLOW}\u${NC}@${DARK_YELLOW}${HOSTNAME}${NC}"
    local __cur_location="${CYAN}\w${NC}"

    local __git_branch="$(__git_ps1)"

    local __git_branch_color="$GREEN"
    if [[ "${__git_branch}" =~ "*" ]]; then     # if repository is dirty
        __git_branch_color="$RED"
    elif [[ "${__git_branch}" =~ "$" ]]; then   # if there is something stashed
        __git_branch_color="$LIGHT_YELLOW"
    elif [[ "${__git_branch}" =~ "%" ]]; then   # if there are only untracked files
        __git_branch_color="$LIGHT_PURPLE"
    elif [[ "${__git_branch}" =~ "+" ]]; then   # if there are staged files
        __git_branch_color="$LIGHT_CYAN"
    fi

    __git_branch="${__git_branch_color}$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')${NC}"

    local __prompt_tail=" \n> "

    PS1="$__user_and_host:$__cur_location$__git_branch$__prompt_tail"
}

# configure PROMPT_COMMAND which is executed each time before PS1
PROMPT_COMMAND=color_my_prompt

# if .git-prompt.sh exists, set options and execute it
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWUPSTREAM="auto"
GIT_PS1_HIDE_IF_PWD_IGNORED=true
GIT_PS1_SHOWCOLORHINTS=true
. git-prompt.sh

PROMPT_COMMAND="echo -ne '\033]0;${USER}@${HOSTNAME}\007';$PROMPT_COMMAND"
export PROMPT_COMMAND
