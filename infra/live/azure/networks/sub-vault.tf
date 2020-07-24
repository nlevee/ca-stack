resource "azurerm_subnet" "from_vault" {
  name                 = "sub-vault"
  resource_group_name  = module.variables.azure_resource_group
  virtual_network_name = azurerm_virtual_network.global.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.KeyVault"]
}

resource "azurerm_subnet_network_security_group_association" "sub-vault-default" {
  subnet_id                 = azurerm_subnet.from_vault.id
  network_security_group_id = module.vault_nsg.nsg_id
}
