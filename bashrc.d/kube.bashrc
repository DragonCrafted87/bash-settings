#!/bin/bash

function k8s-show-all ()
{
    clear
    kubectl get nodes | (read -r; printf "%s\n" "$REPLY"; sort) && echo ''
    kubectl get pods --all-namespaces | (read -r; printf "%s\n" "$REPLY"; sort) && echo ''
    kubectl get deployments --all-namespaces | (read -r; printf "%s\n" "$REPLY"; sort) && echo ''
    kubectl get replicasets --all-namespaces | (read -r; printf "%s\n" "$REPLY"; sort) && echo ''
    kubectl get daemonsets --all-namespaces | (read -r; printf "%s\n" "$REPLY"; sort) && echo ''
    kubectl get job --all-namespaces | (read -r; printf "%s\n" "$REPLY"; sort) && echo ''
    kubectl get cronjob --all-namespaces | (read -r; printf "%s\n" "$REPLY"; sort) && echo ''
    kubectl get services --all-namespaces | (read -r; printf "%s\n" "$REPLY"; sort) && echo ''
    kubectl get endpoints --all-namespaces | (read -r; printf "%s\n" "$REPLY"; sort) && echo ''
}

function k8s-copy-cifs-secret-to-namespace ()
{
    kubectl get secret cifs-secret -n storage -o yaml | sed s/"namespace: storage"/"namespace: $1"/ | kubectl apply -f -
}

function k8s-apply-all ()
{
    kubectl.exe apply -f . --recursive
}
