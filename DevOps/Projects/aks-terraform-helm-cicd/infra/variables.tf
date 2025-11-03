// Variable definitions and sensible defaults for a development AKS environment.

variable "rg_name" {
  type    = string
  default = "devops.experiment"
  description = "The name of the existing Azure Resource Group to deploy into."
}

variable "location" {
  type    = string
  default = "eastus"
  description = "Azure region for resources."
}

variable "aks_name" {
  type    = string
  default = "aks-demo"
  description = "Base name for the AKS cluster and related resources."
}

# Optional explicit ACR name (if null, main.tf generates one from random_string)
variable "acr_name" {
  type        = string
  default     = null
  description = "ACR name; lowercase 5–50 alnum. If null, a name is generated."
}

variable "log_analytics_name" {
  type    = string
  default = "law-aks-demo"
  description = "Name for the Log Analytics workspace used by Container Insights."
}

# node sizes picked for low cost
variable "system_vm_size" {
  type    = string
  default = "Standard_B2s"
  description = "VM SKU for the system node pool (small, cost-efficient)."
}

variable "user_vm_size" {
  type    = string
  default = "Standard_D2as_v5"
  description = "VM SKU for the user node pool (workloads)."
}

# Key terms
// - variable: input to Terraform module/config allowing reuse and parameterization.
// - default: value used when no override provided (CLI, tfvars, or environment).
// - description: helpful text for users and tooling.
