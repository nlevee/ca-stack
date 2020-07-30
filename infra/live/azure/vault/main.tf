
data "azurerm_client_config" "current" {}

data "terraform_remote_state" "networks" {
  backend = "local"

  config = {
    path = "${path.module}/../networks/terraform.tfstate"
  }
}

# vault for ca-issuer
resource "azurerm_key_vault" "issuer-vault" {
  name                     = "${module.variables.azure_resource_group}-issuer-vault"
  location                 = module.variables.azure_location
  resource_group_name      = module.variables.azure_resource_group
  tenant_id                = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled      = true
  purge_protection_enabled = false

  sku_name = "standard"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"

    ip_rules = var.ip_rules

    # assign access from subnet
    virtual_network_subnet_ids = [
      data.terraform_remote_state.networks.outputs.subnet_ca_id,
      data.terraform_remote_state.networks.outputs.subnet_issuer_id,
    ]
  }
}

# vault for vm usage
resource "azurerm_key_vault" "vm-vault" {
  name                     = "${module.variables.azure_resource_group}-vm-vault"
  location                 = module.variables.azure_location
  resource_group_name      = module.variables.azure_resource_group
  tenant_id                = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled      = true
  purge_protection_enabled = false

  sku_name = "standard"

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"

    ip_rules = var.ip_rules

    # assign access from subnet
    virtual_network_subnet_ids = [
      data.terraform_remote_state.networks.outputs.subnet_ca_id,
      data.terraform_remote_state.networks.outputs.subnet_issuer_id,
    ]
  }
}
