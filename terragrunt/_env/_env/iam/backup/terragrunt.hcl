locals {
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  vars             = merge(merge(merge(local.global_vars.locals, local.account_vars.locals), local.region_vars.locals), local.environment_vars.locals)
  name             = regex("[a-zA-Z0-9\\-\\_]+$", get_terragrunt_dir())
}

terraform {
  source = "tf/"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  enabled         = true
  restore_enabled = false
  iam_role_name   = dependency.backup.outputs.role_name
}

dependency "backup" {
  config_path = "../../backup/${local.name}"
}
