locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl")) # This works because find_in_parent_folders always works at the context of the child configuration.
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  vars        = merge(local.global_vars.locals, local.env_vars.locals, local.region_vars.locals)
  path_dirs        = regex("([\\w]+)-([\\w]+)$", get_terragrunt_dir()) # it returns table <env> / <subdomain> / public
  zone_name  = local.path_dirs[0]
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-route53//modules/records?ref=v2.11.1"
}

inputs = {
  zone_id = values(dependency.r53_parent.outputs.route53_zone_zone_id)[0]

  # Records will be provided inside environment specific terragrunt file to achieve environment specific records
  records = []
}

dependency "r53_parent" {
  config_path = "../../zone/example.com"
}
