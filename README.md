# Get K3D

First install k3d which is a wrapper for k3s by using one of the commands below - For more info refer : https://github.com/rancher/k3d

wget : `wget -q -O - https://raw.githubusercontent.com/rancher/k3d/master/install.sh | bash`

curl : `curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh | bash`

# K3S cluster creation / Setup helm

`k3d create --name dev` <-- Create k3s cluster name as "dev", you can give a cluster name as your wish

Hope you've already installed kubectl if not refer : https://kubernetes.io/docs/tasks/tools/install-kubectl/

`export KUBECONFIG="$(k3d get-kubeconfig --name='dev')"` <-- set KUBECONFIG to use kubectl

`kubectl -n kube-system create serviceaccount tiller` <-- create service account for tiller

`kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller` <-- set cluster admin role for tiller

If you don't have helm installed, refer https://helm.sh/docs/intro/install/

`helm init --service-account tiller` <-- initialize helm to use the tiller account

# Create namespaces accordingly

This is totally up to you, you can have multiple namespaces or single namespace

`kubectl create namespace dev`

`kubectl create namespace staging`

`kubectl create namespace prod`

# Deploy Airflow with celery workers , Dask with workers and Flask API

Please refer airflow, dask and flask directories for information.

# Create K3S cluster on AWS / Private Docker registry

Please refer k3s-cluster directory for infomation.