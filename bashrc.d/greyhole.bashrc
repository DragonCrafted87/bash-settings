#!/bin/bash

function gh-command ()
{
    kubectl exec -it -n storage "$(kubectl get -n storage pod --selector=role=greyhole -o jsonpath='{.items..metadata.name}')" -- $1
}

function gh-status ()
{
    gh-command 'greyhole --view-queue'
    gh-command 'greyhole --stats'
    gh-command 'greyhole --status'
}

function gh-delete-pod ()
{
    kubectl delete -n storage pod $(kubectl get -n storage pod --selector=role=greyhole -o jsonpath='{.items..metadata.name}')
}
