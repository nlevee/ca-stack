# add network secgroup
resource "azurerm_network_security_group" "default" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
}

# add defaults rules 
resource "azurerm_network_security_rule" "deny-all-inbound" {
  name                        = "Deny-AllInBound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.default.name
}
resource "azurerm_network_security_rule" "deny-all-outbound" {
  name                        = "Deny-AllOutBound"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.default.name
}
