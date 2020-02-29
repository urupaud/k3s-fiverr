#!/bin/bash

mkdir -p /etc/rancher/k3s/

cat <<EOF > /etc/rancher/k3s/registries.yaml
mirrors:
  "${docker-registry-fqdn}":
    endpoint:
      - "https://${docker-registry-fqdn}"
configs:
  "${docker-registry-fqdn}":
    auth:
      username: ${docker-registry-username} # this is the registry username
      password: ${docker-registry-password} # this is the registry password
EOF

#echo "18.233.158.53  registry.emi.pe" >> /etc/hosts

until (curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v${k3s-version}' INSTALL_K3S_EXEC='agent --node-label InstanceType=Ondemand' K3S_CLUSTER_SECRET='${k3s-cluster-secret}' K3S_URL='https://${k3s-url}:6443' sh -); do
  echo 'k3s did not install correctly'
  sleep 2
done