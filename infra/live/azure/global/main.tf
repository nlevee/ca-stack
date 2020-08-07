resource "azurerm_resource_group" "main" {
  name     = module.variables.azure_resource_group
  location = module.variables.azure_location
}
