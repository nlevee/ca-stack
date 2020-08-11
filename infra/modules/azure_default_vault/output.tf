output "vault_id" {
  value = azurerm_key_vault.default.id
}

output "vault_uri" {
  value = azurerm_key_vault.default.vault_uri
}

output "vault_name" {
  value = module.azure_naming.key_vault.name_unique
}
