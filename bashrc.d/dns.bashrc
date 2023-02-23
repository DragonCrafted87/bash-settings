#!/bin/bash

function dns-pods ()
{
    kubectl get -n dns pod --selector=role=unbound -o jsonpath='{.items..metadata.name}'
    echo ""
}

function dns-command ()
{
    IFS=' ' read -r -a array <<< "$(dns-pods)"
    for element in "${array[@]}"
    do
        echo "$element"
        kubectl exec -it -n dns "$element" \
            --  "$@"
    done
}

function dns-describe-pods ()
{
    pods=$(dns-pods)
    kubectl describe -n dns pod "$pods"
}

function dns-pod-logs ()
{
    IFS=' ' read -r -a array <<< "$(dns-pods)"
    for element in "${array[@]}"
    do
        echo "$element"
        kubectl logs -n dns "$element"
        echo
        echo
        echo
    done
}

function dns-delete-all-pods ()
{
    pods=$(dns-pods)
    # shellcheck disable=SC2086
    kubectl delete -n dns pod $pods
}
