# create ca-issuer network interfaces
resource "azurerm_network_interface" "ca-vault" {
  name                = "userspace-vault-nic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.from_vault_network_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "ca-issuer" {
  name                = "userspace-issuer-nic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.to_ca-issuer_network_id
    private_ip_address_allocation = "Dynamic"
  }
}
