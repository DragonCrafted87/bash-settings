#!/bin/bash

function k8s-show-all ()
{
  clear
  kubectl get nodes
  echo ''
  kubectl get all -A
  echo ''
  kubectl get StorageClass -A
  echo ''
  kubectl get pv -A
  echo ''
  kubectl get pvc -A
  echo ''
}

function k8s-copy-cifs-secret-to-namespace ()
{
  kubectl get secret cifs-secret -n storage -o yaml | sed s/"namespace: storage"/"namespace: $1"/ | kubectl apply -f -
}
