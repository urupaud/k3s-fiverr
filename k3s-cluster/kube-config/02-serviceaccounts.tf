resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_service_account" "tiller-prod" {
  metadata {
    name = "tiller"
    namespace = "prod"
  }

  image_pull_secret {
    name = "${kubernetes_secret.docker-registry-prod.metadata.0.name}"
  }

  automount_service_account_token = true

  depends_on = [kubernetes_secret.docker-registry-prod]

}

resource "kubernetes_service_account" "tiller-staging" {
  metadata {
    name = "tiller"
    namespace = "staging"
  }

  image_pull_secret {
    name = "${kubernetes_secret.docker-registry-staging.metadata.0.name}"
  }

  automount_service_account_token = true

  depends_on = [kubernetes_secret.docker-registry-staging]

}