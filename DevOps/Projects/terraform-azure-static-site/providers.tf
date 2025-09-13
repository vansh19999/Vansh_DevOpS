provider "azurerm" {
  features {}

  # Make subscription explicit to avoid "could not be determined" issues.
  subscription_id = var.subscription_id

  # You have only RG-scope Owner; prevent subscription-scope RP auto-registration.
  resource_provider_registrations = "none"
}
