module "s3_backup-main_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "4.0.1"

  name        = "s3"
  environment = var.environment
  namespace   = var.namespace
  attributes  = ["main"]

  acl                = "private"
  user_enabled       = false
  versioning_enabled = true
  sse_algorithm      = "AES256"
}

module "s3_bucket-main-storage" {
  source  = "cloudposse/s3-bucket/aws"
  version = "4.0.1"

  name        = "s3"
  environment = var.environment
  namespace   = var.namespace
  attributes  = ["example", "storage"]

  acl                = "private"
  enabled            = var.environment == "prod" ? true : false
  user_enabled       = false
  versioning_enabled = false
}
