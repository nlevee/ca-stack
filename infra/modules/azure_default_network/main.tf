resource "azurerm_virtual_network" "network" {
  name                = var.network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.address_range]
}
resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [cidrsubnet(var.address_range, 8, 1)]
  service_endpoints    = var.service_endpoints
}
resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = var.nsg_id
}
