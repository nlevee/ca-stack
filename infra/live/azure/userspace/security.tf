# link app sec group to network interface
resource "azurerm_network_interface_application_security_group_association" "ask_issue_asg" {
  network_interface_id          = azurerm_network_interface.issuer.id
  application_security_group_id = data.terraform_remote_state.networks.outputs.asg_ask_issue_id
}

resource "azurerm_network_interface_application_security_group_association" "behind_proxy_asg" {
  network_interface_id          = azurerm_network_interface.proxy.id
  application_security_group_id = data.terraform_remote_state.networks.outputs.asg_behind_proxy_id
}
