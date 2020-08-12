module "variables" {
  source = "../../../modules/variables"

  workspace   = var.workspace
  name_suffix = var.name_suffix
}

variable "workspace" {
  default = "azure-staging"
}

variable "name_suffix" {
  default = ""
}

variable "ip_rules" {
  type    = list(string)
  default = []
}
