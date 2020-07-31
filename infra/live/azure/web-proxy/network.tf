# create web-proxy network interface
resource "azurerm_network_interface" "web" {
  name                = "WebProxyWebNic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.subnet_web_id
    private_ip_address_allocation = "Dynamic"
  }
}

# create ca-issuer network interfaces
resource "azurerm_network_interface" "issuer" {
  name                = "WebProxyIssuerNic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.subnet_issuer_id
    private_ip_address_allocation = "Dynamic"
  }
}

# add ip addr in issuer subnet
resource "azurerm_private_dns_a_record" "web_proxy" {
  name                = "web-proxy"
  zone_name           = data.terraform_remote_state.networks.outputs.private_zone_name
  resource_group_name = module.variables.azure_resource_group
  ttl                 = 300
  records             = [azurerm_network_interface.issuer.private_ip_address]
}
