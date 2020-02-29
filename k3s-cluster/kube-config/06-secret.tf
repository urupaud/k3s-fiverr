resource "kubernetes_secret" "docker-registry-staging" {
  metadata {
    name = "docker-registry"
    namespace = "staging"
  }

  data = {
    ".dockercfg" = "${file("${path.module}/files/docker-registry.json")}"
  }

  type = "kubernetes.io/dockercfg"
}

resource "kubernetes_secret" "docker-registry-prod" {
  metadata {
    name = "docker-registry"
    namespace = "prod"
  }

  data = {
    ".dockercfg" = "${file("${path.module}/files/docker-registry.json")}"
  }

  type = "kubernetes.io/dockercfg"
}