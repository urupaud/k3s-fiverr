# Get K3D

First install k3d which is a wrapper for k3s by using one of the commands below - For more info refer : https://github.com/rancher/k3d

wget -q -O - https://raw.githubusercontent.com/rancher/k3d/master/install.sh | bash 
curl -s https://raw.githubusercontent.com/rancher/k3d/master/install.sh

# K3S cluster creation / Setup helm

`k3d create --name dev` <-- Create k3s cluster name as "dev", you can give a cluster name as your wish

Hope you've already have installed kubectl if not refer : https://kubernetes.io/docs/tasks/tools/install-kubectl/

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

# Deploy Airflow with Celery workers

This will deploy airflow with celery workers / redis / postgresql as pods, here I've put my python code / DAG to https://github.com/urupaud/airflow-test.git and refer it in **dags.git.url** parameter. Also you can have number of celery workers as pods by changing **workers.replicas** parameter.

For more information about the parameters refer : https://github.com/helm/charts/tree/master/stable/airflow#helm-chart-configuration

`helm install --name airflow stable/airflow --namespace <staging|prod|dev> --set dags.git.gitSync.enabled=true,dags.git.url=https://github.com/urupaud/airflow-test.git,dags.git.ref=master,dags.git.gitSync.refreshTime=10s,dags.initContainer.enabled=true,workers.replicas=<number_of_worker_pods>`

Wait for sometime till pods come to "Running" status, you can see the status by using

`kubectl get pods --all-namespaces`

Once pods are up and running you'll be able to access airflow web , flower by using their service cluster IPs and respective ports. To get those information use

`kubectl get services -n <prod|staging|dev>`