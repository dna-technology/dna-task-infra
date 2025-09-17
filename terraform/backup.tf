### Backup vault for general purposes

module "backup-account" {
  count   = lookup(var.backup_account-enabled, var.environment) ? 1 : 0
  source  = "cloudposse/backup/aws"
  version = "0.14.1"

  namespace        = var.namespace
  environment      = var.environment
  enabled          = true
  plan_enabled     = true
  vault_enabled    = true
  iam_role_enabled = true
  attributes       = ["account"]
  rules = [{
    name              = "daily"
    schedule          = "cron(10 13 ? * * *)"
    start_window      = 60
    completion_window = 240
    lifecycle = {
      cold_storage_after = 7
      delete_after       = 30
    }
    copy_action = {
      destination_vault_arn = "arn:aws:backup:123456789012:vault/examplexample"
      lifecycle = {
        cold_storage_after = 1
        delete_after       = 60
      }
    }
  }]

  backup_resources = [
    "arn:aws:s3:::*",
  ]
  not_resources = [
    "arn:aws:s3:::*-test-*",
    "arn:aws:s3:::tmp-*"
  ]
  kms_key_arn = module.backup-kms-account[0].key_arn
}

module "backup-kms-account" {
  count = lookup(var.backup_account-enabled, var.environment) ? 1 : 0

  source  = "cloudposse/kms-key/aws"
  version = "0.12.2"

  namespace               = var.namespace
  environment             = var.environment
  attributes              = ["account"]
  description             = format("Used for AWS Backup - %s", join("-", [var.namespace, var.environment, "account"]))
  deletion_window_in_days = 1
  enable_key_rotation     = false
  multi_region            = false
  alias                   = format("alias/%s-%s", "backup", "account")
}


module "backup-iam-account" {
  count  = lookup(var.backup_account-enabled, var.environment) ? 1 : 0
  source = "git::ssh://github.com/terraform-aws-modules/terraform-aws-policy-attachment?ref=v1.0.0"

  policy_attachments = [
    "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup",
    "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  ]
  role_name = module.backup-account[0].role_name
}
