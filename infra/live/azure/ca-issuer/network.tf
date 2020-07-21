# create ca-issuer network interfaces
resource "azurerm_network_interface" "ca-vault" {
  name                = "ca-vault-nic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.from_vault_network_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "ca-issuer" {
  name                = "ca-issuer-nic"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.networks.outputs.to_ca-issuer_network_id
    private_ip_address_allocation = "Dynamic"
  }
}

# add sec group to allow 8888 inbound traffic
resource "azurerm_network_security_group" "allow-cfssl-inbound" {
  name                = "AllowCfsslInbound"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group

  security_rule {
    name                       = "AllowCfsslInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8888"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_network_interface_security_group_association" "ca-issuer-secgroup-cfssl" {
  network_interface_id      = azurerm_network_interface.ca-issuer.id
  network_security_group_id = azurerm_network_security_group.allow-cfssl-inbound.id
}
