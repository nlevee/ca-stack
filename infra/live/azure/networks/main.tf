module "network_ca" {
  source = "../../../modules/azure_default_network"

  network_name        = "CaNet"
  resource_group_name = module.variables.azure_resource_group
  location            = module.variables.azure_location
  address_range       = "10.1.0.0/16"
  service_endpoints   = ["Microsoft.KeyVault"]
  nsg_id              = module.vault_nsg.nsg_id
}
module "firewall_ca" {
  source = "../../../modules/azure_default_firewall"

  network_name         = "CaNet"
  resource_group_name  = module.variables.azure_resource_group
  location             = module.variables.azure_location
  subnet_address_range = "10.1.10.0/24"
}
resource "azurerm_subnet_route_table_association" "route_firewall_ca" {
  subnet_id      = module.network_ca.subnet_ids[0]
  route_table_id = module.firewall_ca.route_table_id
}

module "network_proxy" {
  source = "../../../modules/azure_default_network"

  network_name        = "ProxyNet"
  resource_group_name = module.variables.azure_resource_group
  location            = module.variables.azure_location
  address_range       = "10.2.0.0/16"
  service_endpoints   = ["Microsoft.KeyVault"]
  nsg_id              = module.default_nsg.nsg_id
  subnet_names        = ["subnetIssuer", "subnetWeb"]
}
module "firewall_proxy" {
  source = "../../../modules/azure_default_firewall"

  network_name         = "ProxyNet"
  resource_group_name  = module.variables.azure_resource_group
  location             = module.variables.azure_location
  subnet_address_range = "10.2.10.0/24"
}
resource "azurerm_subnet_route_table_association" "route_firewall_proxy" {
  count = 2

  subnet_id      = module.network_proxy.subnet_ids[count.index]
  route_table_id = module.firewall_proxy.route_table_id
}
