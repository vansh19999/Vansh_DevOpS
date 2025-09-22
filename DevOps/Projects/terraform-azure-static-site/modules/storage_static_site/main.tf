# Generates a random string suffix to ensure the storage account name is globally unique
resource "random_string" "sa_suffix" {
  length  = 6                # Length of the random string
  special = false            # Exclude special characters
  upper   = false            # Use lowercase letters only
}

# Creates an Azure Storage Account for hosting the static website
resource "azurerm_storage_account" "sa" {
  name                     = lower(replace("st${var.project}${random_string.sa_suffix.result}", "/[^0-9a-z]/", ""))
  # Storage account name must be globally unique and only contain lowercase letters and numbers
  resource_group_name      = var.resource_group_name   # The resource group to deploy the storage account into
  location                 = var.location             # Azure region for the storage account
  account_tier             = "Standard"               # Performance tier (Standard or Premium)
  account_replication_type = "LRS"                    # Replication type (Locally Redundant Storage)
  account_kind             = "StorageV2"              # Storage account kind (StorageV2 supports static websites)
  min_tls_version          = "TLS1_2"                 # Minimum TLS version for secure access
  allow_nested_items_to_be_public = false             # Prevents nested items from being publicly accessible
  tags                     = var.tags                 # Tags for resource organization
}

# Enables static website hosting on the storage account
resource "azurerm_storage_account_static_website" "site" {
  storage_account_id = azurerm_storage_account.sa.id  # Reference to the storage account
  index_document     = "index.html"                   # Default file served at root
  error_404_document = "404.html"                     # File served for 404 errors
}

# Uploads the index.html file to the $web container for static site hosting
resource "azurerm_storage_blob" "index" {
  name                   = "index.html"               # Blob name
  storage_account_name   = azurerm_storage_account.sa.name   # Storage account name
  storage_container_name = "$web"                     # Special container for static website files
  type                   = "Block"                    # Blob type (Block blob)
  content_type           = "text/html"                # MIME type
  source_content         = var.index_html             # Content of index.html (passed as variable)
}

# Uploads the 404.html file to the $web container for static site hosting
resource "azurerm_storage_blob" "error404" {
  name                   = "404.html"                 # Blob name
  storage_account_name   = azurerm_storage_account.sa.name   # Storage account name
  storage_container_name = "$web"                     # Special container for static website files
  type                   = "Block"                    # Blob type (Block blob)
  content_type           = "text/html"                # MIME type
  source_content         = "<h1>404 - Not Found</h1>" # Content of 404.html (hardcoded here)
}
