#!/bin/bash

until (curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v${k3s-version}' INSTALL_K3S_EXEC='server' K3S_CLUSTER_SECRET='${k3s-cluster-secret}' sh -); do
  echo 'k3s did not install correctly'
  sleep 2
done

until kubectl get pods -A | grep 'Running';
do
  echo 'Waiting for k3s startup'
  sleep 5
done