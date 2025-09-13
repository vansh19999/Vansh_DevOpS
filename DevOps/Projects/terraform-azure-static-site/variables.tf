variable "subscription_id" {
  type        = string
  default     = null
  description = "Azure Subscription ID; set via -var or env."
}

variable "existing_rg_name" {
  type        = string
  description = "Name of your existing RG where you are Owner (e.g., Experimental)."
}

variable "project" {
  type        = string
  default     = "tfstaticsite"
  description = "Moniker used in names & tags."
}

variable "index_html" {
  type        = string
  default     = "<h1>Hello from Terraform on Azure 🎉</h1>"
  description = "Inline HTML content for the demo homepage."
}

variable "location_override" {
  type        = string
  default     = null
  description = "Override the RG location if needed; otherwise uses RG's location."
}
