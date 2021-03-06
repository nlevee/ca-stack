module "cfssl_vault" {
  source = "../../../modules/azure_default_vault"

  vault_name          = "cfssl"
  resource_group_name = module.variables.azure_resource_group
  ip_rules            = var.ip_rules
  subnet_ids = [
    data.terraform_remote_state.networks.outputs.subnet_issuer_id,
    data.terraform_remote_state.networks.outputs.subnet_web_id,
  ]
}
module "issuer_vault" {
  source = "../../../modules/azure_default_vault"

  vault_name          = "issuer"
  resource_group_name = module.variables.azure_resource_group
  ip_rules            = var.ip_rules
  subnet_ids = [
    data.terraform_remote_state.networks.outputs.subnet_ca_id,
    data.terraform_remote_state.networks.outputs.subnet_issuer_id,
    data.terraform_remote_state.networks.outputs.subnet_web_id,
  ]
}
module "vm_vault" {
  source = "../../../modules/azure_default_vault"

  vault_name          = "vm"
  resource_group_name = module.variables.azure_resource_group
  ip_rules            = var.ip_rules
  subnet_ids = [
    data.terraform_remote_state.networks.outputs.subnet_ca_id,
    data.terraform_remote_state.networks.outputs.subnet_issuer_id,
    data.terraform_remote_state.networks.outputs.subnet_web_id,
  ]
}
