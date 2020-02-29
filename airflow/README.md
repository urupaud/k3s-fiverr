# Deploy Airflow with Celery workers

This will deploy airflow with celery workers / redis / postgresql as pods, here I've put my python code / DAGs into **dags** directory here.

First build the airflow docker image locally with dags directory using following command.

`docker build -t airflow:local .` 

Now we need to import locally built docker image to K3S cluster, to do that run the following command.

`k3d import-images -n <k3s_cluster_name> airflow:local`

Once all above are done, move to **charts** directory here, where it contains helm chart for airflow with celery workers / redis / postgresql deployments and execute following command.

`helm install --name airflow . --values values-dev.yaml --namespace <dev|staging|prod>`

Wait for sometime till pods come to "Running" status, you can see the status by using

`kubectl get pods --all-namespaces`

Once pods are up and running you'll be able to access airflow web , flower by using their endpoints. To get endpoints use

`kubectl get services -n <dev|staging|prod>` <-- You'll be able to see airflow-web and air-flow folwer external IPs here, access them by using their external IPs and Ports.

eg - http://172.18.0.2:5555 <-- Airflow flower
     http://172.18.0.2:8080 <-- Airflow web

You can change the number of celery workers as pods by changing **workers.replicas** parameter.

`helm install --name airflow . --values values-dev.yaml --namespace dev --set workers.replicas=3` - to deploy on localhost in dev namespace

`helm install --name airflow . --values values-staging.yaml --namespace staging --set workers.replicas=3` - to deploy on aws cluster in staging namespace

`helm install --name airflow . --values values-prod.yaml --namespace prod --set workers.replicas=3` - to deploy on aws cluster in prod namespace

For more information about the parameters refer : https://github.com/helm/charts/tree/master/stable/airflow#helm-chart-configuration

Here by using ingress, airflow web ui hostname set to **dev-airflow.emi.pe** so hostname will redirect to http://172.18.0.2:8080 which is airflow web ui service on cluster and airflow flower hostname set to **dev-flower.emi.pe** so hostname will redirect to http://172.18.0.2:5555 which is airflow flower ui service on cluster (make sure to put host entry when doing it locally). You can set desired hostname by simply changing the **host** variable in respective environment's value yaml file. 

In order to push the docker image to private docker registry, use following commands.

`docker build -t airflow:latest .`

`docker login https://registry.emi.pe`

`docker tag airflow:latest registry.emi.pe/airflow:latest`

`docker push registry.emi.pe/airflow:latest`

If you refer to charts directory **values-prod.yaml** and **values-prod.yaml** files you'll be able to see variables called **nodeSelector** by using this variable you can select on which node you want to deploy your paticular deployment.

eg - nodeSelector: {InstanceType: "Ondemand"} <- This will deploy to instances where we have the kubernetes label InstanceType set to Ondemand.
     nodeSelector: {InstanceType: "Spot"} <- This will deploy to instances where we have the kubernetes label InstanceType set to Spot.