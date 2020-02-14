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

`helm install --name airflow . --values values-dev.yaml --namespace <dev|staging|prod> --set workers.replicas=3`

For more information about the parameters refer : https://github.com/helm/charts/tree/master/stable/airflow#helm-chart-configuration