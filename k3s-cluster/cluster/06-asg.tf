resource "aws_autoscaling_group" "k3s_server" {
  name_prefix         = "k3s-server"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.k3s-public-subnet-01.id, aws_subnet.k3s-public-subnet-02.id, aws_subnet.k3s-public-subnet-03.id]

  target_group_arns = [
    aws_lb_target_group.k3s-server-6443.arn
  ]

  launch_template {
    id      = aws_launch_template.k3s_server.id
    version = "$Latest"
  }

  depends_on = [aws_launch_template.k3s_server, aws_lb_target_group.k3s-server-6443]
}

resource "aws_autoscaling_group" "k3s_agent" {
  name_prefix         = "k3s-agent"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.k3s-public-subnet-01.id, aws_subnet.k3s-public-subnet-02.id, aws_subnet.k3s-public-subnet-03.id]

  launch_template {
    id      = aws_launch_template.k3s_agent.id
    version = "$Latest"
  }

  depends_on = [aws_launch_template.k3s_agent]
}

resource "aws_autoscaling_group" "k3s_agent_spot" {
  name_prefix         = "k3s-agent-spot"
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.k3s-public-subnet-01.id, aws_subnet.k3s-public-subnet-02.id, aws_subnet.k3s-public-subnet-03.id]
  launch_configuration = aws_launch_configuration.k3s_agent_spot.id

  tag {
    key                 = "Name"
    value               = "k3s-agent-spot"
    propagate_at_launch = true
  }

  depends_on = [aws_launch_configuration.k3s_agent_spot]

}