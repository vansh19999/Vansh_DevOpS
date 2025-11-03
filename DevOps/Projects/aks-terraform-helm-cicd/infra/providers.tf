terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.9"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # For quick start this repo uses local state. Switch to a remote backend (azurerm, s3, etc.) for team use.
  # backend "azurerm" {}
}

provider "azurerm" {
  # 'features {}' is required but currently empty; place provider-specific settings here if needed.
  features {}
}

# Key terms
# - provider: plugin that lets Terraform interact with an API (azurerm for Azure).
# - backend: where Terraform state is stored; commented out here (local used by default).
# - required_providers: declares provider plugins and versions to ensure reproducible behavior.
