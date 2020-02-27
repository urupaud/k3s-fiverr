#Security group / rules for docker-registry servers
resource "aws_security_group" "sg-docker-registry" {
  name        = "sgregistry"
  description = "This security group is for docker-registry servers."
  vpc_id = var.docker-registry-vpc-id
  tags = {
    Name = "sgdocker-registry"
  }
}

resource "aws_security_group_rule" "sg-docker-registry-in-http" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg-docker-registry.id}"
}

resource "aws_security_group_rule" "sg-docker-registry-in-https" {
  type            = "ingress"
  from_port       = 443
  to_port         = 443
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg-docker-registry.id}"
}

resource "aws_security_group_rule" "sg-docker-registry-in-ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg-docker-registry.id}"
}

resource "aws_security_group_rule" "sg-docker-registry-out-all-any" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.sg-docker-registry.id}"
}