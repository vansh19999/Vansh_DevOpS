output "primary_web_endpoint" {
  description = "Static website endpoint."
  value       = azurerm_storage_account.sa.primary_web_endpoint
}
