output "from_vault_network_id" {
  value = azurerm_subnet.from_vault.id
}

output "to_vault_network_id" {
  value = azurerm_subnet.to_vault.id
}

output "to_ca-issuer_network_id" {
  value = azurerm_subnet.to_ca-issuer.id
}
