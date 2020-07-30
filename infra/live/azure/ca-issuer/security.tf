# link app sec group to network interface
resource "azurerm_network_interface_application_security_group_association" "issuer_asg" {
  network_interface_id          = azurerm_network_interface.ca_issuer.id
  application_security_group_id = data.terraform_remote_state.networks.outputs.asg_issuer_id
}
