module "network_ca" {
  source = "../../../modules/azure_default_network"

  network_name        = "CaNet"
  resource_group_name = module.variables.azure_resource_group
  location            = module.variables.azure_location
  address_range       = "10.1.0.0/16"
  service_endpoints   = ["Microsoft.KeyVault"]
  nsg_id              = module.vault_nsg.nsg_id
}

module "network_proxy" {
  source = "../../../modules/azure_default_network"

  network_name        = "ProxyNet"
  resource_group_name = module.variables.azure_resource_group
  location            = module.variables.azure_location
  address_range       = "10.2.0.0/16"
  service_endpoints   = ["Microsoft.KeyVault"]
  nsg_id              = module.default_nsg.nsg_id
  subnet_count        = 2
}
