terraform {
  required_version = ">= 1.6.0"
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.30.0" }
    helm       = { source = "hashicorp/helm",       version = ">= 2.12.0" }
  }
  # Optional: keep azurerm backend enabled so you can switch to remote state later.
  backend "azurerm" {}
}

# Uses your kubeconfig to talk to the target cluster.
provider "kubernetes" { config_path = var.kubeconfig_path }

# Helm v3 provider (no Tiller). Installs charts into the cluster.
provider "helm" {
  kubernetes { config_path = var.kubeconfig_path }
}
