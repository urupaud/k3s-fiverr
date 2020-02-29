resource "kubernetes_role_binding" "tiller-binding-prod" {
  metadata {
    name = "tiller-binding"
    namespace = "prod"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "tiller"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "prod"
  }

  depends_on = [kubernetes_service_account.tiller]
}

resource "kubernetes_role_binding" "tiller-binding-staging" {
  metadata {
    name = "tiller-binding"
    namespace = "staging"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "tiller"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "staging"
  }

  depends_on = [kubernetes_service_account.tiller]
}