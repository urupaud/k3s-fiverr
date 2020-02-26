# K3S cluster on AWS

These terraform modules will create k3s cluster on AWS with following specifications.

**One VPC with 3 private and 3 public subnets**

**One k3s master server with Ondemand instance type**

**One k3s agent node with Ondemand instance type**

**One k3s agent node with Spot instance type**

**One network loadbalancer to work as k3s cluster api / master endpoint** 

You can simply change the number of instances you need by changing following variables in paticuler auto scaling group resources in **06-asg.tf** file.

`desired_capacity    = 1`
`max_size            = 2`
`min_size            = 1`

Before start please go through the **variables.tf** file and replace variable values according to your needs.

# Special notes

In the bootstrap,

k3s Ondemand instances will be labeled with kubernetes label **InstanceType=Ondemand** 

k3s Spot instances will be labeled with kubernetes label **InstanceType=Spot**

so we can use these labels in helm deployments to deploy applications as per your need.

All k3s agents will be setup with the docker registry information which you provide in **variables.tf** so the agents will be able to pull the docker images from it.

# How to Run

Execute the terraform commands in following order inside the directory.

`terraform init`

`terraform apply`

Once everything is created you'll get dns record of k3s master api endpoint.

# Connect kubectl with the cluster

SSH in to k3s-master server by using key pair which you've provided for **key-name** varibale in **variables.tf**.

`ssh -i <key_name>.pem ubuntu@<master_server_ip>`

Now copy the content of /etc/rancher/k3s/k3s.yaml file and put them on your local machines $HOME/.kube/config.

Finally replace the line in config file **server: https://127.0.0.1:6443** to **server: https://<dns_record_of_k3s_master_api>:6443**

example - server: https://127.0.0.1:6443 -> https://k3s-server-lb-7be5ffb891415acc.elb.us-east-1.amazonaws.com:6443

At this point you should have access to k3s cluster on AWS.