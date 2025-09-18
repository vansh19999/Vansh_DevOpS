# 1) Namespace for Argo CD
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.argocd_namespace
    labels = {
      "app.kubernetes.io/part-of" = "argocd"
    }
  }
}

# 2) Argo CD chart installation
resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = var.argocd_namespace
  create_namespace = false

  # Learning setup: insecure HTTP + LoadBalancer service for argocd-server.
  # Production: prefer ClusterIP + Ingress + TLS + SSO (OIDC) + RBAC hardening.
  values = [yamlencode({
    configs = { params = { "server.insecure" = true } }
    server  = { service = { type = var.argocd_server_service_type }, metrics = { enabled = true } }
    controller = { metrics = { enabled = true } }
    repoServer = { metrics = { enabled = true } }
    dex = { enabled = true } # For SSO in real setups; configure with AAD/OIDC
  })]
}
