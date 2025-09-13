data "azurerm_resource_group" "exp" {
  name = var.existing_rg_name
}

locals {
  location = coalesce(var.location_override, data.azurerm_resource_group.exp.location)
  tags = {
    project    = var.project
    managed_by = "terraform"
    owner      = "vansh"
    env        = terraform.workspace
  }
}

module "static_site" {
  source              = "./modules/storage_static_site"
  resource_group_name = data.azurerm_resource_group.exp.name
  location            = local.location
  project             = var.project
  tags                = local.tags
  index_html          = var.index_html
}
