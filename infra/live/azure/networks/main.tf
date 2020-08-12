# create vnet and subnets for CA
module "network_ca" {
  source = "../../../modules/azure_default_network"

  network_name        = "CaNet"
  resource_group_name = local.resource_group_name
  address_range       = "10.1.0.0/16"
  service_endpoints   = ["Microsoft.KeyVault"]
}
resource "azurerm_subnet_network_security_group_association" "ca" {
  count = length(module.network_ca.subnet_ids)

  subnet_id                 = module.network_ca.subnet_ids[count.index]
  network_security_group_id = module.vault_nsg.nsg_id
}

# create vnet and subnets for Proxy
module "network_proxy" {
  source = "../../../modules/azure_default_network"

  network_name        = "ProxyNet"
  resource_group_name = local.resource_group_name
  address_range       = "10.2.0.0/16"
  service_endpoints   = ["Microsoft.KeyVault"]
  subnet_names        = ["subnetIssuer", "subnetWeb"]
}
resource "azurerm_subnet_network_security_group_association" "proxy" {
  count = length(module.network_proxy.subnet_ids)

  subnet_id                 = module.network_proxy.subnet_ids[count.index]
  network_security_group_id = module.default_nsg.nsg_id
}
