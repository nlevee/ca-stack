module "variables" {
  source = "../../../modules/variables"

  workspace = "azure-staging"
}

variable "ip_rules" {
  type    = list
  default = []
}
