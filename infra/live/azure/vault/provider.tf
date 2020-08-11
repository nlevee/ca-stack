# Configure the Azure Provider
provider "azurerm" {
  version = "~> 2.0"
  features {}
}

data "azurerm_client_config" "current" {}

data "terraform_remote_state" "networks" {
  backend = "local"

  config = {
    path = "${path.module}/../networks/terraform.tfstate"
  }
}
