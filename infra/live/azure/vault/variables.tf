module "variables" {
  source = "../../../modules/variables"

  workspace = var.workspace
}

variable "workspace" {
  default = "azure-staging"
}

variable "ip_rules" {
  type    = list
  default = []
}
