#!/bin/bash

function gh-command ()
{
  kubectl exec -it -n storage "$(kubectl get -n storage pod --selector=role=greyhole -o jsonpath='{.items..metadata.name}')" -- greyhole $1
}

function gh-status ()
{
  gh-command --view-queue
  gh-command --stats
  gh-command --status
}
