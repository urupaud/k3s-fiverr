variable "docker-registry-region" {
  description = "docker registry AWS Region"
  default     = "us-east-1"
}

variable "ami-id"{
  description = "docker registry instance ami id"
  default = "ami-07ebfd5b3428b6f4d"
}

variable "docker-registry-vpc-id"{
  description = "vpc id of the docker registry server"
  default = "vpc-70cee70a"
}

variable "instance-type"{
  description = "instance type for docker registr"
  default = "t2.micro"
}

variable "key-name"{
  description = "key pair for instance"
  default = "k3s"
}

variable "docker-registry-public-subnet-id"{
  description = "subnet id of docker registry server"
  default = "subnet-d3475cfd"
}

variable "docker-registry-fqdn"{
  description = "docker registry fqdn"
  default = "registry.emi.pe"
}

variable "docker-resgitry-credentials"{
  description = "docker registry credentials"
  default = "admin:$2y$05$qhiXl61JHE3NG10iIOjFMOwfvZ49k3jAFZAatTDW9RwDBQ0yU5I2m"
}