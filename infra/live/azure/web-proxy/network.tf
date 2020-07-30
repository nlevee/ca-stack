# create web-proxy network interface
resource "azurerm_network_interface" "proxy" {
  name                = "WebProxyProxyNic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.subnet_proxy_id
    private_ip_address_allocation = "Dynamic"
  }
}

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
