provider "aws" {
  region = var.region
}

data "aws_region" "current" {}

module "ecr" {

  source = "../../../modules/develeap/ecr"

  ecr_repository_name  = var.ecr_repository_name
  scan_on_push         = var.scan_on_push
  timeouts_delete      = var.timeouts_delete
  image_tag_mutability = var.image_tag_mutability
}


