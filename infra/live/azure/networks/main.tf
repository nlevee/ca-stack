resource "azurerm_virtual_network" "global" {
  name                = "${module.variables.azure_resource_group}-network"
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group
  address_space       = ["10.0.0.0/16"]
}
