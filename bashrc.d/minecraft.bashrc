#!/bin/bash

function mc-command ()
{
    kubectl exec -it -n games "$(kubectl get -n games pod --selector=role=minecraft -o jsonpath='{.items..metadata.name}')" -- "$@"
}

function mc-logs ()
{
    kubectl logs -n games "$(kubectl get -n games pod --selector=role=minecraft -o jsonpath='{.items..metadata.name}')" -f
}

function mc-describe ()
{
    kubectl describe -n games pod "$(kubectl get -n games pod --selector=role=minecraft -o jsonpath='{.items..metadata.name}')"
}

function mc-rcon ()
{
    mc-command mcrcon --password rcon 127.0.0.1
}

function mc-delete-pod ()
{
    kubectl delete -n games pod "$(kubectl get -n games pod --selector=role=minecraft -o jsonpath='{.items..metadata.name}')"
}

function mc-update-mods ()
{
    if [ -z "$1" ]; then
        MINECRAFT_VERSION='1.18.1'
    else
        MINECRAFT_VERSION="$1"
    fi

    /clang64/bin/python3.exe -I \
        ~/bash-settings/scripts/mod_downloader.py \
        'S:\Games\MineCraft\modlist.conf' \
        'D:\Games\MultiMC\instances\Fabric_Primary\.minecraft\mods' \
        "$MINECRAFT_VERSION"

}
