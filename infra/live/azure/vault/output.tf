output "vm_vault_id" {
  value = azurerm_key_vault.vm-vault.id
}

output "vm_vault_name" {
  value = azurerm_key_vault.vm-vault.name
}

output "issuer_vault_id" {
  value = azurerm_key_vault.issuer-vault.id
}

output "issuer_vault_name" {
  value = azurerm_key_vault.issuer-vault.name
}
