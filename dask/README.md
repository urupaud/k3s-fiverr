# Dask deployment on K3S cluster using helm charts.

Since we need to push our own code to jupyter to run dask jobs, first create a jupyter docker image with your code. Here I've put sample python code to **test_code** directory. And then build a docker image as below.

`docker build -t jupyter:local .`

Now we need to import locally built docker image to K3S cluster, to do that run the following command.

`k3d import-images -n <k3s_cluster_name> jupyter:local`

Once all above are done, move to **charts** directory here, where it contains helm chart for dask / jupyter deployments and execute following command.

`helm install --name dask . --values values-dev.yaml --namespace <dev|staging|prod> --set webUI.servicePort=8080,jupyter.servicePort=8081`

Here we have to set port values for jupyter and dask web ui since there might be a chance to conflict default port 80.

Once pods are up and running you'll be able to access jupyterlab and dask by using their endpoints. To get endpoints use

`kubectl get services -n <dev|staging|prod>` <-- You'll be able to see dask-jupyter and dask-scheduler external IPs here, access them by using their external IPs and Ports.

eg - http://172.18.0.2:8081 <-- jupyterlab
     http://172.18.0.2:8080 <-- dask


By default this deployment will deploy 3 dask workers, you can simply change it by setting **worker.replicas** parameter with helm install command. For more information refer : https://github.com/helm/charts/tree/master/stable/dask

`helm install --name dask . --values values-dev.yaml --namespace dev --set webUI.servicePort=8080,jupyter.servicePort=8081 --set worker.replicas=1` - to deploy on localhost in dev namespace

`helm install --name dask . --values values-staging.yaml --namespace staging --set webUI.servicePort=8080,jupyter.servicePort=8081 --set worker.replicas=1` - to deploy on aws cluster in staging namespace

`helm install --name dask . --values values-prod.yaml --namespace prod --set webUI.servicePort=8080,jupyter.servicePort=8081 --set worker.replicas=1` - to deploy on aws cluster in prod namespace

Here by using ingress, dask hostname set to **dev-dask.emi.pe** so hostname will redirect to http://172.18.0.2:8080 which is dask service on cluster and jupyterlab hostname set to **dev-jupyter.emi.pe** so hostname will redirect to http://172.18.0.2:8081 which is jupyterlab service on cluster (make sure to put host entry when doing it locally). You can set desired hostname by simply changing the **hostname** variables in respective environment's value yaml file.

In order to push the docker image to private docker registry, use following commands.

`docker build -t jupyter:latest .`

`docker login https://registry.emi.pe`

`docker tag jupyter:latest registry.emi.pe/jupyter:latest`

`docker push registry.emi.pe/jupyter:latest`

If you refer to charts directory **values-prod.yaml** and **values-prod.yaml** files you'll be able to see variables called **nodeSelector** by using this variable you can select on which node you want to deploy your paticular deployment.

eg - nodeSelector: {InstanceType: "Ondemand"} <- This will deploy to instances where we have the kubernetes label InstanceType set to Ondemand.
     nodeSelector: {InstanceType: "Spot"} <- This will deploy to instances where we have the kubernetes label InstanceType set to Spot.