# create ca-issuer network interfaces
resource "azurerm_network_interface" "ca_issuer" {
  name                = "CaIssuerIssuerNic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.subnet_issuer_id
    private_ip_address_allocation = "Dynamic"
  }
}

# add ip addr in issuer subnet
resource "azurerm_private_dns_a_record" "ca_issuer" {
  name                = "ca-issuer"
  zone_name           = data.terraform_remote_state.networks.outputs.private_zone_name
  resource_group_name = module.variables.azure_resource_group
  ttl                 = 300
  records             = [azurerm_network_interface.ca_issuer.private_ip_address]
}
