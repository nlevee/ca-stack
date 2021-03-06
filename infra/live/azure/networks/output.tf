output "subnet_ca_id" {
  value = module.network_ca.subnet_ids[0]
}

output "subnet_issuer_id" {
  value = module.network_proxy.subnet_ids[0]
}

output "subnet_web_id" {
  value = module.network_proxy.subnet_ids[1]
}


output "private_zone_id" {
  value = azurerm_private_dns_zone.proxy.id
}

output "private_zone_name" {
  value = azurerm_private_dns_zone.proxy.name
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

output "asg_web_proxy_id" {
  value = azurerm_application_security_group.web-proxy-asg.id
}

output "asg_behind_proxy_id" {
  value = azurerm_application_security_group.behind-proxy-asg.id
}
