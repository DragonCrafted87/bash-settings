#!/bin/bash

export ANSIBLE_ROLES_PATH=~/.ansible/roles

function ansible-install-requirements ()
{
  ansible-galaxy install -r requirements.yml
}
