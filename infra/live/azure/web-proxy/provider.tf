# Configure the Azure Provider
provider "azurerm" {
  version = "~> 2.0"
  features {}
}

# get network state
data "terraform_remote_state" "networks" {
  backend = "local"

  config = {
    path = "${path.module}/../networks/terraform.tfstate"
  }
}

# get vault state
data "terraform_remote_state" "vault" {
  backend = "local"

  config = {
    path = "${path.module}/../vault/terraform.tfstate"
  }
}

# get issuer state
data "terraform_remote_state" "issuer" {
  backend = "local"

  config = {
    path = "${path.module}/../ca-issuer/terraform.tfstate"
  }
}
