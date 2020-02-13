# Dask deployment on K3S cluster using helm charts.

`helm repo add dask https://helm.dask.org/` <-- Add dask helm repo to k3s cluster

`helm repo update` <-- update the helm repositories

Since we need to push our own code to jupyter to run dask jobs, first create a jupyter docker image with your code. Here I've put sample python code to **test_code** directory. And then build a docker image as below.

`docker build -t jupyter:local .`

Now we need to import locally built docker image to K3S cluster, to do that run the following command.

`k3d import-images -n <k3s_cluster_name> jupyter:local`

Once all above is done, move to **charts** directory here, where it contains helm chart for dask / jupyter deployments and execute following command.

`helm install --name dask . --values values-dev.yaml --namespace <dev|staging|prod> --set webUI.servicePort=8080,jupyter.servicePort=8081`

By default this deployment will deploy 3 dask workers, you can simply change it by setting **worker.replicas** parameter with helm install command. For more information refer : https://github.com/helm/charts/tree/master/stable/dask