variable "k3s-region" {
  description = "regions of k3s cluster"
  default     = "us-east-1"
}

variable "k3s-vpc-cidr" {
  description = "CIDR for the k3s VPC"
  default     = "10.120.32.0/20"
}

variable "k3s-public-subnet-cidr-01" {
  description = "CIDR for the k3s public subnet 01"
  default     = "10.120.32.0/24"
}

variable "k3s-public-subnet-cidr-02" {
  description = "CIDR for the k3s public subnet 02"
  default     = "10.120.34.0/24"
}

variable "k3s-public-subnet-cidr-03" {
  description = "CIDR for the k3s public subnet 03"
  default     = "10.120.36.0/24"
}

variable "k3s-private-subnet-cidr-01" {
  description = "CIDR for the k3s private subnet 01"
  default     = "10.120.33.0/24"
}

variable "k3s-private-subnet-cidr-02" {
  description = "CIDR for the k3s private subnet 02"
  default     = "10.120.35.0/24"
}

variable "k3s-private-subnet-cidr-03" {
  description = "CIDR for the k3s private subnet 03"
  default     = "10.120.37.0/24"
}

variable "k3s-image-id" {
  description = "k3s image id"
  default     = "ami-07ebfd5b3428b6f4d"
}

variable "k3s-instance-type" {
  description = "k3s instance type for master and ondemand instances"
  default     = "t3.micro"
}

variable "k3s-version" {
  description = "k3s version"
  default     = "0.9.1"
}

variable "docker-registry-fqdn" {
  description = "Fully qualified domain name of docker registry"
  default     = "registry.emi.pe"
}

variable "docker-registry-username" {
  description = "docker registry username"
  default     = "admin"
}

variable "docker-registry-password" {
  description = "docker registry password"
  default     = "123456"
}

variable "key-name" {
  description = "key pair name for servers"
  default     = "k3s"
}

variable "spot-price" {
  description = "spot instane price"
  default     = "0.0062"
}

variable "spot-instance-type" {
  description = "spot instane type"
  default     = "t3.small"
}