resource "azurerm_virtual_network" "global" {
  name                = "${module.variables.azure_resource_group}-network"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group
  address_space       = ["10.0.0.0/16"]
}

module "network_ca" {
  source = "../../../modules/azure_default_network"

  network_name        = "CaNet"
  resource_group_name = module.variables.azure_resource_group
  location            = module.variables.azure_location
  address_range       = "10.1.0.0/16"
  service_endpoints   = ["Microsoft.KeyVault"]
  nsg_id              = module.vault_nsg.nsg_id
}


module "network_issuer" {
  source = "../../../modules/azure_default_network"

  network_name        = "IssuerNet"
  resource_group_name = module.variables.azure_resource_group
  location            = module.variables.azure_location
  address_range       = "10.2.0.0/16"
  service_endpoints   = ["Microsoft.KeyVault"]
  nsg_id              = module.default_nsg.nsg_id
}

module "network_proxy" {
  source = "../../../modules/azure_default_network"

  network_name        = "ProxyNet"
  resource_group_name = module.variables.azure_resource_group
  location            = module.variables.azure_location
  address_range       = "10.3.0.0/16"
  nsg_id              = module.default_nsg.nsg_id
}

module "network_web" {
  source = "../../../modules/azure_default_network"

  network_name        = "WebNet"
  resource_group_name = module.variables.azure_resource_group
  location            = module.variables.azure_location
  address_range       = "10.4.0.0/16"
  nsg_id              = module.default_nsg.nsg_id
}
