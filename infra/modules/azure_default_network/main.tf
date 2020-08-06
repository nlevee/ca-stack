# add network
resource "azurerm_virtual_network" "network" {
  name                = var.network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_range]
}

# add subnets
resource "azurerm_subnet" "default" {
  count = var.subnet_count

  name                 = "${var.subnet_name}-${count.index}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [cidrsubnet(var.address_range, 8, count.index)]
  service_endpoints    = var.service_endpoints
}

# assoc to sec group
resource "azurerm_subnet_network_security_group_association" "default" {
  count = var.subnet_count

  subnet_id                 = azurerm_subnet.default[count.index].id
  network_security_group_id = var.nsg_id
}
