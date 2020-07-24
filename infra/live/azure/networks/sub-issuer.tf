resource "azurerm_subnet" "to_ca-issuer" {
  name                 = "sub-issuer"
  resource_group_name  = module.variables.azure_resource_group
  virtual_network_name = azurerm_virtual_network.global.name
  address_prefixes     = ["10.0.3.0/24"]
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet_network_security_group_association" "sub-issuer-default" {
  subnet_id                 = azurerm_subnet.to_ca-issuer.id
  network_security_group_id = module.default_nsg.nsg_id
}
