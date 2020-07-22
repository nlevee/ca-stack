resource "azurerm_subnet" "to_ca-issuer" {
  name                 = "sub-issuer"
  resource_group_name  = module.variables.azure_resource_group
  virtual_network_name = azurerm_virtual_network.global.name
  address_prefixes     = ["10.0.3.0/24"]
}
