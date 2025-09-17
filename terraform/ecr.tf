locals {
  is_prod_or_nonprod_workspace = contains(["prod", "nonprod"], var.environment)
}

module "log_router_ecr" {
  source = "git::ssh://github.com/terraform-aws-modules/terraform-aws-ecr"

  enabled     = local.is_prod_or_nonprod_workspace ? true : false
  environment = var.environment
  namespace   = var.namespace
  name        = "log-router"

  max_image_count      = 100
  scan_images_on_push  = true
  image_tag_mutability = "MUTABLE"
  encryption_configuration = {
    encryption_type = "AES256",
    kms_key         = null
  }

  principals_readonly_access = [for p in lookup(var.log_router_ecr_read_only_account_map, var.environment, []) : format("arn:aws:iam::%s:root", p)]
}
