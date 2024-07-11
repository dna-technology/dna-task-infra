locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  vars = merge(local.global_vars.locals, local.env_vars.locals)
}

terraform {
  source = "git::https://github.com/cloudposse/terraform-aws-alb.git"
}

inputs = {
  enable     = true
  attributes = ["common"]

  vpc_id             = dependency.vpc.vpc_id
  security_group_ids = dependency.vpc.default_security_group_id
  subnet_ids         = dependency.vpc.private_subnets

  internal         = true
  http_enabled     = true
  http_redirect    = false
  https_enabled    = false

  https_ssl_policy	= "ELBSecurityPolicy-2015-05"

  listener_https_fixed_response = {
    content_type = "text/html"
    message_body = "Access denied"
    status_code  = 403
  }
}

dependency "vpc" {
  config_path = "${local.vars.root_dir}/${local.vars.region}/vpc"
}
