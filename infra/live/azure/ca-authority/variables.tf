module "variables" {
  source = "../../../modules/variables"

  workspace = var.workspace
}

variable "workspace" {
  default = "azure-staging"
}

variable "image_name" {
  type        = string
  description = "image name created by packer (ex: debian10-bkp-gen2-ca-authority-1595325783)"
}
