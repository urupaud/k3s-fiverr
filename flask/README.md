# Sample Flask API deployment on K3S cluster using helm charts.

First build the docker image locally using following command.

`docker build -t flask:local .` 

Now we need to import locally built docker image to K3S cluster, to do that run the following command.

`k3d import-images -n <k3s_cluster_name> flask:local`

Once all above is done, move to **charts** directory here, where it contains helm chart for flask api deployment and execute following command.

`helm install --name flaskapi . --values values-dev.yaml --namespace <dev|staging|prod>`

Once pods are up and running you'll be able to access flask api by using it's endpoint. To get endpoints use

`kubectl get services -n <dev|staging|prod>` <-- You'll be able to see flaskapi-service external IP here, access them by using their external IP and Port.

eg - http://172.18.0.2:5000 <-- flaskapi

By default this deployment will deploy only 1 api, if you want to change it, change the value of **replicas** variable in **values-dev.yaml** in charts directory.