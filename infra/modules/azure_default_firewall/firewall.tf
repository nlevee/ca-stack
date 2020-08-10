# subnet for firewall config
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.network_name
  address_prefixes     = [var.subnet_address_range]
}

# add public ip for firewall
resource "azurerm_public_ip" "firewall" {
  name                = "${var.network_name}FwPublicIp"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# add firewall
resource "azurerm_firewall" "default" {
  name                = "${var.network_name}Fw"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "internal"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

# add default route table
resource "azurerm_route_table" "default" {
  name                          = "${var.network_name}FwRouteTable"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false
}

# add default rule to next hop firewall
resource "azurerm_route" "default_firewall" {
  name                   = "default"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.default.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.default.ip_configuration[0].private_ip_address
}
