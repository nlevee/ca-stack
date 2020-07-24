# link app sec group to network interface
resource "azurerm_network_interface_application_security_group_association" "ca-issuer-asg" {
  network_interface_id          = azurerm_network_interface.ca-issuer.id
  application_security_group_id = data.terraform_remote_state.networks.outputs.asg_ask_issue_id
}