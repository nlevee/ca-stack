resource "azurerm_private_dns_zone" "proxy" {
  name                = "${lower(local.resource_group_name)}.lo"
  resource_group_name = local.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "proxy_net" {
  name                  = "proxy"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.proxy.name
  virtual_network_id    = module.network_proxy.network_id
  registration_enabled  = false
}
