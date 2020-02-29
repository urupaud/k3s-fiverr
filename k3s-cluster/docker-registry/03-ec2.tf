data "template_file" "docker-registry-userdata"{
    template = "${file("${path.module}/templates/docker-registry.sh.tpl")}"

    vars = {
        docker-registry-fqdn = "${var.docker-registry-fqdn}"
        docker-resgitry-credentials = "${var.docker-resgitry-credentials}"
    }
}

resource "aws_instance" "docker-registry" {
  ami                         = var.ami-id
  instance_type               = var.instance-type
  key_name                    = var.key-name
  subnet_id                   = var.docker-registry-public-subnet-id
  vpc_security_group_ids      = ["${aws_security_group.sg-docker-registry.id}"]
  associate_public_ip_address = true
  source_dest_check           = false

  user_data = "${base64encode(data.template_file.docker-registry-userdata.rendered)}"

  tags = {
    "Name" = "docker-registry"
  }
}

resource "aws_eip" "docker-registry" {
  instance = "${aws_instance.docker-registry.id}"
  vpc      = true
  tags = {
    Name = "docker-registry"
  }

  depends_on = [aws_instance.docker-registry]

}