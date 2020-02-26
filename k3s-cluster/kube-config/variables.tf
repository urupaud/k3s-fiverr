variable "k3s-region" {
  description = "regions of k3s cluster"
  default     = "us-east-1"
}

variable "k3s-vpc-id" {
  description = "ID of the k3s VPC"
  default     = "vpc-087e99da20294e795"
}

variable "k3s-pub-subnet-id-01" {
  description = "ID of the k3s public subnet id 01"
  default     = "subnet-0e9acef1fbab30775"
}

variable "k3s-pub-subnet-id-02" {
  description = "ID of the k3s public subnet id 02"
  default     = "subnet-0b846210c2d4dfc29"
}

variable "k3s-pub-subnet-id-03" {
  description = "ID of the k3s public subnet id 03"
  default     = "subnet-0b16d22c9e20d3be2"
}

variable "k3s-agent-sg" {
  description = "ID of the k3s agents sg"
  default     = "sg-0545ce4ca71e8509b"
}

variable "k3s-alb-sg" {
  description = "ID of the k3s alb sg"
  default     = "sg-06de75a03ce89b610"
}