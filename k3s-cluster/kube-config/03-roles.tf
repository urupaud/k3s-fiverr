resource "kubernetes_role" "tiller-prod" {
  metadata {
    name = "tiller"
    namespace = "prod"
  }

  rule {
    api_groups = ["", "batch", "extensions", "apps", "networking.k8s.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role" "tiller-staging" {
  metadata {
    name = "tiller"
    namespace = "staging"
  }

  rule {
    api_groups = ["", "batch", "extensions", "apps", "networking.k8s.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}