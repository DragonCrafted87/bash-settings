#!/bin/bash

export FORMAT="\nID\t{{.ID}}\nIMAGE\t{{.Image}}\nCOMMAND\t{{.Command}}\nCREATED\t{{.RunningFor}}\nSTATUS\t{{.Status}}\nPORTS\t{{.Ports}}\nNAMES\t{{.Names}}\n"

function docker-build ()
{
    docker build \
        --no-cache \
        --pull \
        --file Dockerfile \
        --tag "$1" \
        .
}

function docker-build-local ()
{
    docker build \
        --no-cache \
        --file Dockerfile \
        --tag "$1" \
        .
}

function docker-stop ()
{
    docker stop "$(docker ps -a -q)"
}

function docker-remove-all-stopped-containers ()
{
    docker container prune --force
}

function docker-remove-all-images ()
{
    docker-remove-all-stopped-containers

    #delete images
    docker system prune --all --force
}
