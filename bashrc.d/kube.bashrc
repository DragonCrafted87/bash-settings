#!/bin/bash

function kube-show-all ()
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
