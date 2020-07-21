module "variables" {
  source = "../../../modules/variables"

  workspace = "azure-staging"
}

variable "image_name" {
  type        = string
  description = "image name created by packer (ex: debian10-bkp-gen2-ca-authority-1595325783)"
}
