locals {
  global_vars      = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  vars             = merge(merge(merge(local.global_vars.locals, local.account_vars.locals), local.region_vars.locals), local.environment_vars.locals)
  name             = regex("[a-zA-Z0-9\\-\\_]+$", get_terragrunt_dir())
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "${path_relative_from_include()}/../modules/terraform-aws-routes"
}

inputs = {
  route_table_ids_count  = length(dependency.vpc.outputs.private_route_table_ids)
  route_table_ids        = dependency.vpc.outputs.private_route_table_ids
  destination_cidr_block = "10.28.8.0/24"
  tgw_id                 = local.vars.transit_gateway_id
}

dependency "vpc" {
  config_path = "../../vpc"
}
