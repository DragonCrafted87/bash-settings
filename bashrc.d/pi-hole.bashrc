#!/bin/bash

function pi-hole-pods ()
{
    IFS=' ' read -r -a array <<< "$(kubectl get -n dns pod --selector=role=pi-hole -o jsonpath='{.items..metadata.name}')"
    for element in "${array[@]}"
    do
        echo "$element"
    done
}

function pi-hole-command ()
{
    IFS=' ' read -r -a array <<< "$(kubectl get -n dns pod --selector=role=pi-hole -o jsonpath='{.items..metadata.name}')"
    for element in "${array[@]}"
    do
        echo "$element"
        kubectl exec -it -n dns "$element" -- pihole $1
    done
}

function pi-hole-disable ()
{
    pi-hole-command disable
}

function pi-hole-status ()
{
    pi-hole-command status
}

function pi-hole-enable ()
{
    pi-hole-command enable
}

function pi-hole-upgrade ()
{
    kubectl delete -n dns pod $(kubectl get -n dns pod --selector=role=pi-hole -o jsonpath='{.items..metadata.name}')
}
