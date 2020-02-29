data "template_file" "k3s-agent-spot-userdata"{
    template = "${file("${path.module}/templates/k3s-agent-spot-userdata.sh.tpl")}"

    vars = {
        k3s-version = "${var.k3s-version}"
        k3s-cluster-secret = random_password.password.result
        k3s-url = aws_lb.k3s-server-lb.dns_name
        docker-registry-fqdn = "${var.docker-registry-fqdn}"
        docker-registry-username = "${var.docker-registry-username}"
        docker-registry-password = "${var.docker-registry-password}"
    }
}

resource "aws_launch_configuration" "k3s_agent_spot" {
  image_id                    = var.k3s-image-id
  instance_type               = var.spot-instance-type
  spot_price                  = var.spot-price
  name_prefix                 = "k3s-agent-spot"
  key_name                    = var.key-name
  user_data_base64            = base64encode(data.template_file.k3s-agent-spot-userdata.rendered)
  security_groups             = [aws_security_group.k3s-agent-sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.k3s-role.name

  root_block_device {
    volume_type = "gp2"
    volume_size = "50"
    encrypted   = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on           = [aws_iam_instance_profile.k3s-role, aws_lb.k3s-server-lb]
}
