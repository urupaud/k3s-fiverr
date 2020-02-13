# Deploy Airflow with Celery workers

This will deploy airflow with celery workers / redis / postgresql as pods, here I've put my python code / DAG to https://github.com/urupaud/airflow-test.git and refer it in **dags.git.url** parameter. Also you can have number of celery workers as pods by changing **workers.replicas** parameter.

For more information about the parameters refer : https://github.com/helm/charts/tree/master/stable/airflow#helm-chart-configuration

`helm install --name airflow stable/airflow --namespace <staging|prod|dev> --set dags.git.gitSync.enabled=true,dags.git.url=https://github.com/urupaud/airflow-test.git,dags.git.ref=master,dags.git.gitSync.refreshTime=10s,dags.initContainer.enabled=true,workers.replicas=<number_of_worker_pods>`

Wait for sometime till pods come to "Running" status, you can see the status by using

`kubectl get pods --all-namespaces`

Once pods are up and running you'll be able to access airflow web , flower by using their endpoints. To get endpoints use

`kubectl describe svc airflow -n <staging|prod|dev>` <-- this will show information related to airflow deployment

You can access airflow web by using endpoint of svc name "airflow-web"

You can access airflow flower by using the endpoint of svc "airflow-flower"