output "vm_vault_id" {
  value = module.vm_vault.vault_id
}

output "vm_vault_name" {
  value = local.vm_vault_name
}

output "vm_vault_uri" {
  value = module.vm_vault.vault_uri
}

output "issuer_vault_id" {
  value = module.issuer_vault.vault_id
}

output "issuer_vault_name" {
  value = local.issuer_vault_name
}

output "issuer_vault_uri" {
  value = module.issuer_vault.vault_uri
}
