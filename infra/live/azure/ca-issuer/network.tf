# create ca-issuer network interfaces
resource "azurerm_network_interface" "ca-issuer" {
  name                = "ca-issuer-nic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.sub_issuer_network_id
    private_ip_address_allocation = "Dynamic"
  }
}
