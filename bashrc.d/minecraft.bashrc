#!/bin/bash

function mc-command ()
{
  kubectl exec -it -n minecraft "$(kubectl get -n minecraft pod --selector=role=minecraft -o jsonpath='{.items..metadata.name}')" -- "$@"
}

function mc-status ()
{
  kubectl logs -n minecraft "$(kubectl get -n minecraft pod --selector=role=minecraft -o jsonpath='{.items..metadata.name}')" -f
}

function mc-rcon ()
{
  mc-command mcrcon --password rcon 127.0.0.1
}
