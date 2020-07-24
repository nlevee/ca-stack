# configure vault & default nsg
module "default_nsg" {
  source = "../../../modules/azure_default_nsg"

  name                = "DefaultNSG"
  resource_group_name = module.variables.azure_resource_group
  location            = module.variables.azure_location
}

module "vault_nsg" {
  source = "../../../modules/azure_default_nsg"

  name                = "VaultNSG"
  resource_group_name = module.variables.azure_resource_group
  location            = module.variables.azure_location
}


# configure app secgroup to defined issuer
resource "azurerm_application_security_group" "ca-issuer-asg" {
  name                = "CaIssuerAppGroup"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group
}

# configure app secgroup to defined who can ask for issue
resource "azurerm_application_security_group" "ask-issue-asg" {
  name                = "AskIssueAppGroup"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group
}

# add rules to secgroup
# Allow traffic in for cfssl
resource "azurerm_network_security_rule" "allow-cfssl-inbound" {
  name                   = "AllowCfsslInbound"
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "8888"
  source_application_security_group_ids = [
    azurerm_application_security_group.ask-issue-asg.id,
  ]
  destination_application_security_group_ids = [
    azurerm_application_security_group.ca-issuer-asg.id,
  ]
  resource_group_name         = module.variables.azure_resource_group
  network_security_group_name = module.default_nsg.nsg_name
}

# Allow trafic out for AzureKeyVault
resource "azurerm_network_security_rule" "allow-keyvault-outbound" {
  name                        = "AllowOutBoundKeyVault"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureKeyVault"
  resource_group_name         = module.variables.azure_resource_group
  network_security_group_name = module.default_nsg.nsg_name
}

resource "azurerm_network_security_rule" "ca-allow-keyvault-outbound" {
  name                        = "AllowOutBoundKeyVault"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureKeyVault"
  resource_group_name         = module.variables.azure_resource_group
  network_security_group_name = module.vault_nsg.nsg_name
}
