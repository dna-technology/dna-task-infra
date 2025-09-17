locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  vars        = merge(local.global_vars.locals, local.env_vars.locals)

  name             = regex("[a-zA-Z0-9\\-\\_]+$", get_terragrunt_dir())
}

terraform {
  source = "git::https://github.com/cloudposse/terraform-aws-kms-key?ref=0.12.1"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  attributes              = [local.name]
  description             = format("Used for AWS Backup - %s", join("-", [local.vars.namespace, local.vars.environment, local.vars.account_name]))
  deletion_window_in_days = 1
  enable_key_rotation     = false
  alias                   = format("alias/%s-%s", local.path_dirs[1], local.path_dirs[2])
}
