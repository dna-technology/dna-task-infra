locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl")) # This works because find_in_parent_folders always works at the context of the child configuration.
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  vars        = merge(local.global_vars.locals, local.env_vars.locals, local.region_vars.locals)

  path_dirs = regex("([\\w\\-\\_\\.]+)$", get_terragrunt_dir()) # it returns array contains name of the directory in directory path started from the last one
  domain_name = concat(".", [local.vars.environment_long, replace(local.path_dirs[0], "environment.", "")])
  zone_comment = "Created and maintained via Terraform and Terragrunt"
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-route53modules/zones//?ref=v2.11.1"
}

inputs = {
  create = true
  zones = {
    local.domain_name = {
      comment = "Created and maintained via Terraform and Terragrunt"
    }
  }
}
