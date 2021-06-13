#!/bin/bash

function git-push-tags ()
{
    git push origin --tags
}

function git-hold-file ()
{
    git update-index --assume-unchanged $1
}

function git-release-file ()
{
    git update-index --no-assume-unchanged $1
}

function git-status-all-repos ()
{
    find . -maxdepth 2 -name .git -type d -execdir sh -c '
          basename -s .git `git config --get remote.origin.url`;
          git status --short --branch;
          echo "";' \;
}

function git-pull-all-repos ()
{
    find . -maxdepth 2 -name .git -type d -execdir sh -c '
          basename -s .git `git config --get remote.origin.url`;
          git pull;
          echo "";' \;
}

function git-init-all-repos ()
{
    find . -maxdepth 2 -name .git -type d -execdir sh -c '
          basename -s .git `git config --get remote.origin.url`;
          git init;
          echo "";' \;
}
