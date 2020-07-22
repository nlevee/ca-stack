output "vm_vault_id" {
  value = azurerm_key_vault.vm-vault.id
}

output "issuer_vault_id" {
  value = azurerm_key_vault.issuer-vault.id
}
