resource "aws_security_group" "k3s-master-sg" {
  name        = "k3s-master-sg"
  description = "Allow communication between master and workers"
  vpc_id      = aws_vpc.k3s-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-master-sg"
  }

  depends_on           = [aws_vpc.k3s-vpc]
}

resource "aws_security_group" "k3s-agent-sg" {
  name        = "k3s-agent-sg"
  description = "Security group for all agents in the cluster"
  vpc_id      = aws_vpc.k3s-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-agent-sg"
  }

  depends_on           = [aws_vpc.k3s-vpc]
}

resource "aws_security_group" "k3s-alb-sg" {
  name        = "k3s-alb-sg"
  description = "ALB security group"
  vpc_id      = aws_vpc.k3s-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-alb-sg"
  }

  depends_on           = [aws_vpc.k3s-vpc]
}

resource "aws_security_group_rule" "self_k3s_server" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s-master-sg.id

  depends_on           = [aws_security_group.k3s-master-sg]
}

resource "aws_security_group_rule" "ssh_k3s_server" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s-master-sg.id

  depends_on           = [aws_security_group.k3s-master-sg]
}

resource "aws_security_group_rule" "ssh_k3s_agent" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s-agent-sg.id

  depends_on           = [aws_security_group.k3s-agent-sg]
}

resource "aws_security_group_rule" "all_k3s_agent" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "TCP"
  cidr_blocks       = [aws_vpc.k3s-vpc.cidr_block]
  security_group_id = aws_security_group.k3s-agent-sg.id

  depends_on           = [aws_security_group.k3s-agent-sg]
}

resource "aws_security_group_rule" "http_k3s_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s-alb-sg.id

  depends_on           = [aws_security_group.k3s-alb-sg]
}

resource "aws_security_group_rule" "https_k3s_alb" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k3s-alb-sg.id

  depends_on           = [aws_security_group.k3s-alb-sg]
}