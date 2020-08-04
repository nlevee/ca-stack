resource "azurerm_private_dns_zone" "stack" {
  name                = "${module.variables.azure_resource_group}.lo"
  resource_group_name = module.variables.azure_resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "proxy_net" {
  name                  = "proxy"
  resource_group_name   = module.variables.azure_resource_group
  private_dns_zone_name = azurerm_private_dns_zone.stack.name
  virtual_network_id    = module.network_proxy.network_id
  registration_enabled  = false
}
