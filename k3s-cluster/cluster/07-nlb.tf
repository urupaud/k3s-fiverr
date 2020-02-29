resource "aws_lb" "k3s-server-lb" {
  name               = "k3s-server-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.k3s-public-subnet-01.id, aws_subnet.k3s-public-subnet-02.id, aws_subnet.k3s-public-subnet-03.id]
}

resource "aws_lb_listener" "k3s-server-port_6443" {
  load_balancer_arn = aws_lb.k3s-server-lb.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k3s-server-6443.arn
  }
}

resource "aws_lb_target_group" "k3s-server-6443" {
  name     = "k3s-server-6443"
  port     = 6443
  protocol = "TCP"
  vpc_id   = aws_vpc.k3s-vpc.id
}