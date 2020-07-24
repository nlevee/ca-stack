output "sub_vault_network_id" {
  value = azurerm_subnet.from_vault.id
}

output "sub_issuer_network_id" {
  value = azurerm_subnet.to_ca-issuer.id
}

output "sub_proxy_network_id" {
  value = azurerm_subnet.user-proxy.id
}


output "default_security_group_name" {
  value = module.default_nsg.nsg_name
}

output "default_security_group_id" {
  value = module.default_nsg.nsg_id
}


output "asg_issuer_id" {
  value = azurerm_application_security_group.ca-issuer-asg.id
}

output "asg_ask_issue_id" {
  value = azurerm_application_security_group.ask-issue-asg.id
}
