#!/bin/bash

function gh-command ()
{
    kubectl exec -it -n storage \
        "$(kubectl get -n storage pod --selector=role=greyhole -o jsonpath='{.items..metadata.name}')" \
        --container greyhole \
        -- \
        "$@"
}

function gh-command-database ()
{
    kubectl exec -it -n storage \
        "$(kubectl get -n storage pod --selector=role=greyhole -o jsonpath='{.items..metadata.name}')" \
        --container mysql \
        -- \
        "$@"
}

function gh-queue ()
{
    gh-command greyhole --view-queue
}

function gh-status ()
{
    gh-queue
    gh-command greyhole --stats
    gh-command greyhole --status
}

function gh-spool ()
{
    gh-command greyhole --process-spool --keepalive
}

function gh-logs ()
{
    kubectl logs -n storage \
        "$(kubectl get -n storage pod --selector=role=greyhole -o jsonpath='{.items..metadata.name}')" \
        --container greyhole
}

function gh-activity-logs ()
{
    gh-command greyhole --status
    gh-command greyhole --logs
}

function gh-delete-pod ()
{
    kubectl delete -n storage pod \
        "$(kubectl get -n storage pod --selector=role=greyhole -o jsonpath='{.items..metadata.name}')"
}
