#!/bin/bash

export ANSIBLE_INVENTORY=~/.ansible/inventory.yml
export ANSIBLE_ROLES_PATH=~/.ansible/roles:./roles
export ANSIBLE_COLLECTIONS_PATHS=~/.ansible/collections
export ANSIBLE_TIMEOUT=120

function ansible-link-files ()
{
    ln -s /home/dragon/repos/local-cluster-configuration/k3s-inventory.yml ~/.ansible/inventory.yml
    ln -s /home/dragon/repos/ansible-roles/ ~/.ansible/roles
    ln -s /home/dragon/repos/ansible-collections/ ~/.ansible/collections
}

function ansible-install-requirements ()
{
    ansible-galaxy install -r requirements.yml
}

function ansible-setup ()
{
    sudo apt update
    sudo apt install software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install ansible
}
