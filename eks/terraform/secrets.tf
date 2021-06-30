resource "kubernetes_service_account" "signon-secrets-management-fred" {
  metadata {
    name = "signon-secrets-management"
  }
}

resource "kubernetes_cluster_role" "signon-secrets-management-role-fred" {
  metadata {
    name = "signon-secrets-management"
  }

  rule {
    api_groups = ["",]
    resources  = ["secrets"]
    verbs      = ["create", "get", "list", "update", "watch", "patch"]
  }
}

resource "kubernetes_cluster_role_binding" "signon-secrets-management-role-binding-fred" {
  metadata {
    name = "signon-secrets-management"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.signon-secrets-management-role-fred.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.signon-secrets-management-fred.metadata.0.name
    namespace = "default"
  }
}
