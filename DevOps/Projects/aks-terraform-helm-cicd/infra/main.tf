// Infra definitions: AKS cluster, ACR, Log Analytics and node pools.
// Comments added to clarify purpose of each block and key fields.

############################################
# Data sources & helpers
############################################
data "azurerm_resource_group" "rg" {
  // Look up an existing resource group by name (provided via variable).
  name = var.rg_name
}

resource "random_string" "suffix" {
  // Generate a short suffix for resources when a fixed name is not provided.
  length  = 6
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# Derive final ACR name if not supplied: uses user-provided name or generated name.
locals {
  acr_name = (
    var.acr_name != null && var.acr_name != ""
  ) ? var.acr_name : "acr${random_string.suffix.result}"
}

############################################
# Log Analytics (lean retention)
# Used by Container Insights (AKS monitoring)
############################################
resource "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30  // Short retention for dev environment

  tags = {
    project = "aks-terraform-helm-cicd"
    env     = "dev"
  }
}

############################################
# Azure Container Registry (Basic)
# Private Docker registry for images used by AKS
############################################
resource "azurerm_container_registry" "acr" {
  name                = local.acr_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "Basic"        // Basic SKU suitable for dev/test
  admin_enabled       = false          // Prefer role-based access

  tags = {
    project = "aks-terraform-helm-cicd"
    env     = "dev"
  }
}

############################################
# AKS (CNI Overlay, OIDC, Workload Identity)
# Primary Kubernetes cluster resource
############################################
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "${var.aks_name}-dns"

  // Security & identity features
  oidc_issuer_enabled       = true   // Required for Workload Identity
  workload_identity_enabled = true   // Use Azure AD Workload Identity for pods

  // Minimal system node pool to host system components/reserved workloads
  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_vm_size
    node_count                   = 1
    only_critical_addons_enabled = true
    type                         = "VirtualMachineScaleSets"
    os_disk_size_gb              = 60
  }

  // Network choices: AKS Azure CNI overlay for simpler pod networking
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
  }

  // Cluster identity for managed control plane operations
  identity {
    type = "SystemAssigned"
  }

  // Enable Container Insights (connects to Log Analytics)
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }

  tags = {
    project = "aks-terraform-helm-cicd"
    env     = "dev"
  }

  // Avoid spurious diffs when AKS performs minor automatic upgrades
  lifecycle {
    ignore_changes = [kubernetes_version]
  }
}

############################################
# User node pool (Spot instances, autoscale 0–3)
# Runs general workloads; cost-sensitive spot VMs used for dev
############################################
resource "azurerm_kubernetes_cluster_node_pool" "user_spot" {
  name                  = "userspt"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.user_vm_size
  mode                  = "User"               // User node pool for workloads
  auto_scaling_enabled  = true
  min_count             = 0
  max_count             = 3

  // Spot instances settings to reduce cost in dev
  priority        = "Spot"
  eviction_policy = "Delete"
  spot_max_price  = -1 // Use pay-as-you-go price cap

  node_labels = {
    pool = "spot"
  }

  tags = {
    project = "aks-terraform-helm-cicd"
    env     = "dev"
  }
}

############################################
# Allow AKS kubelet to pull from ACR
# Grants ACR pull permission to the cluster's kubelet identity
############################################
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

############################################
# Key terms (compact)
############################################
//
// Terraform
// - resource: a cloud object managed by Terraform (e.g., azurerm_kubernetes_cluster).
// - data: read-only data lookup (existing resources).
// - local: computed value used in config.
// - lifecycle.ignore_changes: prevents Terraform from updating a field.
//
// Azure
// - Resource Group: logical container for Azure resources.
// - AKS: Azure Kubernetes Service, managed Kubernetes control plane.
// - ACR: Azure Container Registry, private image registry.
// - Log Analytics: central log store; Container Insights sends cluster metrics/logs here.
//
// AKS / Kubernetes
// - node pool: group of VMs that run Kubernetes pods.
// - system vs user node pool: system hosts control-plane related pods; user hosts workloads.
// - OIDC / Workload Identity: identity model allowing pods to access Azure resources securely.
// - Azure CNI: network plugin that assigns IPs to pods from VNet.
// - Spot instances: preemptible VMs cheaper but can be evicted.
//
// Notes:
// This file is written for a dev environment: single system node, small sizes, spot user pool, short retention.
