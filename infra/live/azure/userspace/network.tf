# create vm-vault network interfaces
resource "azurerm_network_interface" "vm-vault" {
  name                = "userspace-vault-nic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.sub_vault_network_id
    private_ip_address_allocation = "Dynamic"
  }
}

# create ca-issuer network interfaces
resource "azurerm_network_interface" "ca-issuer" {
  name                = "userspace-issuer-nic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.sub_issuer_network_id
    private_ip_address_allocation = "Dynamic"
  }
}

# create web-proxy network interface
resource "azurerm_network_interface" "internal" {
  name                = "userspace-internal-nic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.sub_proxy_network_id
    private_ip_address_allocation = "Dynamic"
  }
}
