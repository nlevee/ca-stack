output "subnet_ca_id" {
  value = module.network_ca.subnet_ids[0]
}

output "subnet_issuer_id" {
  value = module.network_proxy.subnet_ids[0]
}

output "subnet_web_id" {
  value = module.network_proxy.subnet_ids[1]
}

output "proxy_firewall_name" {
  value = module.firewall_proxy.fw_name
}

output "proxy_firewall_public_ip" {
  value = module.firewall_proxy.fw_public_ip
}

output "ca_firewall_name" {
  value = module.firewall_ca.fw_name
}

output "ca_firewall_public_ip" {
  value = module.firewall_ca.fw_public_ip
}


output "private_zone_id" {
  value = azurerm_private_dns_zone.stack.id
}

output "private_zone_name" {
  value = azurerm_private_dns_zone.stack.name
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
