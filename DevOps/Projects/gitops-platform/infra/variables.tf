# Path to your kubeconfig (AKS credentials).
variable "kubeconfig_path" {
  description = "Path to kubeconfig used by Terraform Kubernetes/Helm providers"
  type        = string
  default     = "~/.kube/config"
}

# Namespace for Argo CD control plane.
variable "argocd_namespace" {
  description = "Namespace for Argo CD control plane"
  type        = string
  default     = "argocd"
}

# Pin a stable Argo CD chart version (check Artifact Hub for updates).
variable "argocd_chart_version" {
  description = "Helm chart version for argo-cd"
  type        = string
  default     = "6.11.1"
}

# Expose Argo CD as LoadBalancer (easy for learning) or ClusterIP (prod with Ingress).
variable "argocd_server_service_type" {
  description = "How to expose Argo CD server (LoadBalancer/ClusterIP)"
  type        = string
  default     = "LoadBalancer"
}
