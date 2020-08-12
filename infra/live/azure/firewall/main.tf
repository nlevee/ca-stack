module "firewall_ca" {
  source = "../../../modules/azure_default_firewall"

  network_name         = "CaNet"
  resource_group_name  = local.resource_group_name
  location             = local.resource_group_location
  subnet_address_range = "10.1.10.0/24"
}
resource "azurerm_subnet_route_table_association" "route_firewall_ca" {
  subnet_id      = data.terraform_remote_state.networks.outputs.subnet_ca_id
  route_table_id = module.firewall_ca.route_table_id
}

module "firewall_proxy" {
  source = "../../../modules/azure_default_firewall"

  network_name         = "ProxyNet"
  resource_group_name  = local.resource_group_name
  location             = local.resource_group_location
  subnet_address_range = "10.2.10.0/24"
}
resource "azurerm_subnet_route_table_association" "route_firewall_issuer" {
  subnet_id      = data.terraform_remote_state.networks.outputs.subnet_issuer_id
  route_table_id = module.firewall_proxy.route_table_id
}
resource "azurerm_subnet_route_table_association" "route_firewall_web" {
  subnet_id      = data.terraform_remote_state.networks.outputs.subnet_web_id
  route_table_id = module.firewall_proxy.route_table_id
}
