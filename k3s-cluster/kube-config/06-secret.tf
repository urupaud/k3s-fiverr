data "template_file" "docker-registry"{
    template = "${file("${path.module}/files/docker-registry.json.tpl")}"

    vars = {
        docker-registry-username = "${var.docker-registry-username}"
        docker-registry-password = "${var.docker-registry-password}"
    }
}

resource "kubernetes_secret" "docker-registry-staging" {
  metadata {
    name = "registry.emi.pe"
    namespace = "staging"
  }

  data = {
    ".dockerconfigjson" = data.template_file.docker-registry.rendered
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_secret" "docker-registry-prod" {
  metadata {
    name = "registry.emi.pe"
    namespace = "prod"
  }

  data = {
    ".dockerconfigjson" = data.template_file.docker-registry.rendered
  }

  type = "kubernetes.io/dockerconfigjson"
}