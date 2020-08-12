# configure app secgroup to defined issuer
resource "azurerm_application_security_group" "ca-issuer-asg" {
  name                = "CaIssuerAppGroup"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
}

# configure app secgroup to defined who can ask for issue
resource "azurerm_application_security_group" "ask-issue-asg" {
  name                = "AskIssueAppGroup"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
}

# configure app secgroup to defined who is proxy
resource "azurerm_application_security_group" "web-proxy-asg" {
  name                = "WebProxyAppGroup"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
}

# configure app secgroup to defined who can be proxied
resource "azurerm_application_security_group" "behind-proxy-asg" {
  name                = "BehindProxyAppGroup"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
}

# configure vault & default nsg
module "default_nsg" {
  source = "../../../modules/azure_default_nsg"

  name                = "DefaultNSG"
  resource_group_name = local.resource_group_name
}

module "vault_nsg" {
  source = "../../../modules/azure_default_nsg"

  name                = "VaultNSG"
  resource_group_name = local.resource_group_name
}

locals {
  rules_refs = {
    "Allow-Proxy" = {
      priority               = 105
      access                 = "Allow"
      protocol               = "Tcp"
      source_port_range      = "*"
      destination_port_range = "8080"
      source_application_security_group_ids = [
        azurerm_application_security_group.behind-proxy-asg.id,
      ]
      destination_application_security_group_ids = [
        azurerm_application_security_group.web-proxy-asg.id,
      ]
      network_security_group_name = module.default_nsg.nsg_name
    }
    "Allow-Cfssl" = {
      priority               = 100
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
      network_security_group_name = module.default_nsg.nsg_name
    }
  }
  rules_inbound  = toset(["Allow-Cfssl", "Allow-Proxy"])
  rules_outbound = toset(["Allow-Cfssl", "Allow-Proxy"])
}

# add rules to secgroup
resource "azurerm_network_security_rule" "custom_inbound" {
  for_each = local.rules_inbound

  resource_group_name                        = local.resource_group_name
  name                                       = "${each.key}InBound"
  priority                                   = local.rules_refs[each.key].priority
  direction                                  = "Inbound"
  access                                     = local.rules_refs[each.key].access
  protocol                                   = local.rules_refs[each.key].protocol
  source_port_range                          = local.rules_refs[each.key].source_port_range
  destination_port_range                     = local.rules_refs[each.key].destination_port_range
  source_application_security_group_ids      = local.rules_refs[each.key].source_application_security_group_ids
  destination_application_security_group_ids = local.rules_refs[each.key].destination_application_security_group_ids
  network_security_group_name                = local.rules_refs[each.key].network_security_group_name
}
resource "azurerm_network_security_rule" "custom_outbound" {
  for_each = local.rules_inbound

  resource_group_name                        = local.resource_group_name
  name                                       = "${each.key}OutBound"
  priority                                   = local.rules_refs[each.key].priority
  direction                                  = "Outbound"
  access                                     = local.rules_refs[each.key].access
  protocol                                   = local.rules_refs[each.key].protocol
  source_port_range                          = local.rules_refs[each.key].source_port_range
  destination_port_range                     = local.rules_refs[each.key].destination_port_range
  source_application_security_group_ids      = local.rules_refs[each.key].source_application_security_group_ids
  destination_application_security_group_ids = local.rules_refs[each.key].destination_application_security_group_ids
  network_security_group_name                = local.rules_refs[each.key].network_security_group_name
}

# Allow trafic out for AzureKeyVault
locals {
  nsgs_keyvaul_outbound = [
    module.default_nsg.nsg_name,
    module.vault_nsg.nsg_name,
  ]
}
resource "azurerm_network_security_rule" "allow-keyvault-outbound" {
  count = length(local.nsgs_keyvaul_outbound)

  name                        = "Allow-KeyVaultOutBound"
  priority                    = 512
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "AzureKeyVault"
  resource_group_name         = local.resource_group_name
  network_security_group_name = local.nsgs_keyvaul_outbound[count.index]
}
