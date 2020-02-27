# Create docker registry

First go through the **variables.tf** and update values accordingly.

We have two special variables which are,

1. docker-registry-fqdn - This is the fully qualified domain name for the registry. Here I've used it as `registry.emi.pe`

2. docker-registry-credentials - This is the credentials which will be used to authenticate with the docker registry.

To generate this install `htpasswd` on your local machine and run the command as following.

`htpasswd -Bc registry.passwd admin` - This will create a flat file named as registry.passwd which will contain the http user  credentials in encrypted format. Here we are creating a user as **admin** and it'll prompt you for a password.

Once above step is done, get the content of **registry.passwd** file and add it as a value to **docker-registry-credentials**

Now run following commands,

`terraform init`

`terraform apply`

This will create a docker registry and you'll be able to access it by adding a hostname to your hosts or point dns by route53 or any domain registrar,

example host record - <eip_of_docker_registry_instance> **registry.emi.pe**

# Special note

Please note that here I'm passing **private.key** and **server.crt** of `emi.pe` domain in `templates\docker-registry.sh.tpl` file. If you need to change them please update those keys and certs in that file.