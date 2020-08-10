output "fw_name" {
  value = azurerm_firewall.default.name
}

output "fw_private_ip" {
  value = azurerm_firewall.default.ip_configuration[0].private_ip_address
}

output "fw_public_ip" {
  value = azurerm_public_ip.firewall.ip_address
}

output "route_table_id" {
  value = azurerm_route_table.default.id
}
