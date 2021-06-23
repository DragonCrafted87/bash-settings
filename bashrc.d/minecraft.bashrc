#!/bin/bash

function mc-command ()
{
    kubectl exec -it -n games "$(kubectl get -n games pod --selector=role=minecraft -o jsonpath='{.items..metadata.name}')" -- "$@"
}

function mc-status ()
{
    kubectl logs -n games "$(kubectl get -n games pod --selector=role=minecraft -o jsonpath='{.items..metadata.name}')" -f
}

function mc-show ()
{
    kubectl describe -n games pod "$(kubectl get -n games pod --selector=role=minecraft -o jsonpath='{.items..metadata.name}')"
}

function mc-rcon ()
{
    mc-command mcrcon --password rcon 127.0.0.1
}

function mc-update-mods ()
{
    mod_downloader.py \
        'D:\Games\MultiMC\instances\Fabric_1.17.0\.minecraft\modlist.conf' \
        'D:\Games\MultiMC\instances\Fabric_1.17.0\.minecraft\mods'
}
