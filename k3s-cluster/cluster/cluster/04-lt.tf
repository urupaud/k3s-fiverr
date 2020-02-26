resource "random_password" "password" {
  length = 16
  special = true
  override_special = "_%@"
}


data "template_file" "k3s-master-userdata"{
    template = "${file("${path.module}/templates/k3s-server-userdata.sh.tpl")}"

    vars = {
        k3s-version = "${var.k3s-version}"
        k3s-cluster-secret = random_password.password.result
    }
}

data "template_file" "k3s-agent-ondemand-userdata"{
    template = "${file("${path.module}/templates/k3s-agent-ondemand-userdata.sh.tpl")}"

    vars = {
        k3s-version = "${var.k3s-version}"
        k3s-cluster-secret = random_password.password.result
        k3s-url = aws_lb.k3s-server-lb.dns_name
        docker-registry-fqdn = "${var.docker-registry-fqdn}"
        docker-registry-username = "${var.docker-registry-username}"
        docker-registry-password = "${var.docker-registry-password}"
    }
}

resource "aws_launch_template" "k3s_server" {
  name_prefix   = "k3s-server"
  image_id      = var.k3s-image-id
  instance_type = var.k3s-instance-type
  user_data     = base64encode(data.template_file.k3s-master-userdata.rendered)
  key_name = var.key-name

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      encrypted   = true
      volume_type = "gp2"
      volume_size = "50"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.k3s-role.name
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination = true
    security_groups       = [aws_security_group.k3s-master-sg.id]
  }

  tags = {
    Name = "k3s-server"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "k3s-server"
    }
  }

  depends_on           = [aws_iam_instance_profile.k3s-role, aws_lb.k3s-server-lb]
}

resource "aws_launch_template" "k3s_agent" {
  name_prefix   = "k3s-agent"
  image_id      = var.k3s-image-id
  instance_type = var.k3s-instance-type
  user_data     = base64encode(data.template_file.k3s-agent-ondemand-userdata.rendered)
  key_name = var.key-name

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      encrypted   = true
      volume_type = "gp2"
      volume_size = "50"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.k3s-role.name
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination = true
    security_groups       = [aws_security_group.k3s-agent-sg.id]
  }

  tags = {
    Name = "k3s-agent"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "k3s-agent"
    }
  }

  depends_on           = [aws_iam_instance_profile.k3s-role, aws_lb.k3s-server-lb]
}