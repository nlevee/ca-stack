output "sub_vault_network_id" {
  value = azurerm_subnet.from_vault.id
}

output "sub_issuer_network_id" {
  value = azurerm_subnet.to_ca-issuer.id
}

output "sub_proxy_network_id" {
  value = azurerm_subnet.user-proxy.id
}
