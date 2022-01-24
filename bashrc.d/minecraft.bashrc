#!/bin/bash

function mc-vpp-command ()
{
    kubectl exec -it -n games "$(kubectl get -n games pod --selector=role=minecraft-vpp -o jsonpath='{.items..metadata.name}')" -- "$@"
}

function mc-vpp-logs ()
{
    kubectl logs -n games "$(kubectl get -n games pod --selector=role=minecraft-vpp -o jsonpath='{.items..metadata.name}')" -f
}

function mc-vpp-describe ()
{
    kubectl describe -n games pod "$(kubectl get -n games pod --selector=role=minecraft-vpp -o jsonpath='{.items..metadata.name}')"
}

function mc-vpp-rcon ()
{
    mc-vpp-command mcrcon --password rcon 127.0.0.1
}

function mc-vpp-delete-pod ()
{
    kubectl delete -n games pod "$(kubectl get -n games pod --selector=role=minecraft-vpp -o jsonpath='{.items..metadata.name}')"
}

function mc-uhc-command ()
{
    kubectl exec -it -n games "$(kubectl get -n games pod --selector=role=minecraft-uhc -o jsonpath='{.items..metadata.name}')" -- "$@"
}

function mc-uhc-logs ()
{
    kubectl logs -n games "$(kubectl get -n games pod --selector=role=minecraft-uhc -o jsonpath='{.items..metadata.name}')" -f
}

function mc-uhc-describe ()
{
    kubectl describe -n games pod "$(kubectl get -n games pod --selector=role=minecraft-uhc -o jsonpath='{.items..metadata.name}')"
}

function mc-uhc-rcon ()
{
    mc-uhc-command mcrcon --password rcon 127.0.0.1
}

function mc-uhc-delete-pod ()
{
    kubectl delete -n games pod "$(kubectl get -n games pod --selector=role=minecraft-uhc -o jsonpath='{.items..metadata.name}')"
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
