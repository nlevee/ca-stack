output "subnet_ids" {
  value = azurerm_subnet.default.*.id
}

output "network_id" {
  value = azurerm_virtual_network.network.id
}

output "fw_name" {
  value = azurerm_firewall.default.name
}

output "fw_private_ip" {
  value = azurerm_firewall.default.ip_configuration[0].private_ip_address
}

output "fw_public_ip" {
  value = azurerm_public_ip.firewall.ip_address
}
