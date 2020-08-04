# link app sec group to network interface
resource "azurerm_network_interface_application_security_group_association" "ask_issue_asg" {
  network_interface_id          = azurerm_network_interface.issuer.id
  application_security_group_id = data.terraform_remote_state.networks.outputs.asg_ask_issue_id
}

resource "azurerm_network_interface_application_security_group_association" "web_proxy_asg" {
  network_interface_id          = azurerm_network_interface.issuer.id
  application_security_group_id = data.terraform_remote_state.networks.outputs.asg_web_proxy_id
}

# Allow Proxy to Internet
resource "azurerm_network_security_rule" "allow-internet-outbound" {
  name                        = "Allow-InternetOutBound"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefix       = azurerm_network_interface.web.private_ip_address
  destination_address_prefix  = "Internet"
  resource_group_name         = module.variables.azure_resource_group
  network_security_group_name = data.terraform_remote_state.networks.outputs.default_security_group_name
}

# configure firewall to allow internet dest
resource "azurerm_firewall_network_rule_collection" "web_proxy" {
  name                = "proxy-collection"
  azure_firewall_name = data.terraform_remote_state.networks.outputs.proxy_firewall_name
  resource_group_name = module.variables.azure_resource_group
  priority            = 100
  action              = "Allow"

  rule {
    name = "web"

    source_addresses = [
      azurerm_network_interface.web.private_ip_address,
    ]

    destination_ports = [
      "80", "443"
    ]

    destination_addresses = [
      "*",
    ]

    protocols = [
      "TCP",
    ]
  }
}
