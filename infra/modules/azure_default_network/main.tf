# fetch resource group data
data "azurerm_resource_group" "default" {
  name = var.resource_group_name
}

# add network
resource "azurerm_virtual_network" "default" {
  name                = var.network_name
  location            = data.azurerm_resource_group.default.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_range]
}

# add subnets
resource "azurerm_subnet" "default" {
  count = length(var.subnet_names)

  name                 = var.subnet_names[count.index]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = [cidrsubnet(var.address_range, 8, count.index)]
  service_endpoints    = var.service_endpoints
}
