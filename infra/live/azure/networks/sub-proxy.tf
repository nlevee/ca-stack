resource "azurerm_subnet" "user-proxy" {
  name                 = "sub-proxy"
  resource_group_name  = module.variables.azure_resource_group
  virtual_network_name = azurerm_virtual_network.global.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "sub-proxy-default" {
  subnet_id                 = azurerm_subnet.user-proxy.id
  network_security_group_id = module.default_nsg.nsg_id
}
