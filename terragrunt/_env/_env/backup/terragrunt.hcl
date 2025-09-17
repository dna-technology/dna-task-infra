locals {
  path_dirs        = regex("([\\w\\-\\_\\.]+)$", get_terragrunt_dir()) # it returns table of 2 last dirrectiories: backup / <directory name>
  name             = local.path_dirs[0]
}

terraform {
  source = "git::https://github.com/cloudposse/terraform-aws-backup?ref=0.3.1"
}

inputs = {
  enabled            = true
  plan_enabled       = false
  vault_enabled      = true
  iam_role_enabled   = true
  schedule           = "cron(67 4 FRI * ? *)"
  start_window       = 60
  completion_window  = 240
  cold_storage_after = 3
  delete_after       = 7
  selection_tags = [
    {
      type  = "STRINGEQUALS"
      key   = "aws:ResourceTag/BackupEnabled"
      value = "true"
    }
  ]
  kms_key_arn                    = dependency.kms.outputs.key_arn
}

dependency "kms" {
  config_path = "../kms/${local.name}"
}
