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
