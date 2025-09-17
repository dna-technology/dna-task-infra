locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl")) # This works because find_in_parent_folders always works at the context of the child configuration.
  vars        = merge(local.global_vars.locals, local.env_vars.locals)
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v3.19.0"
}

inputs = {
  name                              = "${local.vars.namespace}-${local.vars.environment}-${local.vars.stage}-internal"
  enable     = true

  name  = join("-", [local.vars.namespace, local.vars.environment, local.vars.stage, local.name])
  azs = ["eu-central-1a"]
  cidr = "10.10.0.0/20"
  private_subnets = ["10.10.0.0/23", "10.10.0.0/23"]
  public_subnets = ["10.10.8.0/23", "10.10.9.0/23"]
  database_subnets = ["10.10.16.0/24", "10.10.17.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  enable_flow_log                   = false
}