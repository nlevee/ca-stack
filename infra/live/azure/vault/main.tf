
data "azurerm_client_config" "current" {}

data "terraform_remote_state" "networks" {
  backend = "local"

  config = {
    path = "${path.module}/../networks/terraform.tfstate"
  }
}

locals {
  cfssl_vault_name  = "${module.variables.azure_resource_group}-cfssl-vault"
  issuer_vault_name = "${module.variables.azure_resource_group}-issuer-vault"
  vm_vault_name     = "${module.variables.azure_resource_group}-vm-vault"
}

module "cfssl_vault" {
  source = "../../../modules/azure_default_vault"

  vault_name          = local.cfssl_vault_name
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group
  ip_rules            = var.ip_rules
  subnet_ids = [
    data.terraform_remote_state.networks.outputs.subnet_issuer_id,
    data.terraform_remote_state.networks.outputs.subnet_web_id,
  ]
}
module "issuer_vault" {
  source = "../../../modules/azure_default_vault"

  vault_name          = local.issuer_vault_name
  location            = module.variables.azure_location
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

  vault_name          = local.vm_vault_name
  location            = module.variables.azure_location
  resource_group_name = module.variables.azure_resource_group
  ip_rules            = var.ip_rules
  subnet_ids = [
    data.terraform_remote_state.networks.outputs.subnet_ca_id,
    data.terraform_remote_state.networks.outputs.subnet_issuer_id,
    data.terraform_remote_state.networks.outputs.subnet_web_id,
  ]
}
