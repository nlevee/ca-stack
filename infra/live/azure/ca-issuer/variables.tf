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

variable "image_name" {
  type        = string
  description = "image name created by packer (ex: debian10-bkp-gen2-ca-issuer-1595335256)"
}
