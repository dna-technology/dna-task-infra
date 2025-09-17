locals {
  global_vars  = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl")) # This works because find_in_parent_folders always works at the context of the child configuration.
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  service_vars = read_terragrunt_config(find_in_parent_folders("service.hcl", "fallback.hcl"), { locals = { tags = {} } })
  vars         = merge(local.global_vars.locals, local.env_vars.locals, local.region_vars.locals, local.service_vars.locals)

  namespace   = local.vars.namespace
  environment = local.vars.environment

  tags = {
    Application = format("%s-%s-%s-%s", local.vars.namespace, local.vars.tenant, local.vars.environment, local.vars.name)
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.vars.region}"
  # AWS Account ID allowed to execute the terragrunt commands
  allowed_account_ids = ["${get_aws_account_id()}"]
}
EOF
}

terraform {
  extra_arguments "global_args" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=30m", "-input=false"]
  }

  extra_arguments "plan_args" {
    commands  = ["plan"]
    arguments = tolist(["-compact-warnings", "-refresh=true", "-out=${get_env("PLANFILE", "tfplan")}"])
  }

  extra_arguments "apply_args" {
    commands  = ["apply"]
    arguments = tolist([get_env("PLANFILE", "tfplan")])
  }
}

remote_state {
  backend = "s3"

  config = {
    encrypt        = false
    region         = "eu-west-1"
    bucket         = "terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    dynamodb_table = "terraform-locks"

    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_credentials_validation = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = {
  label_order = local.vars.label_order
  namespace   = local.vars.namespace
  tenant      = local.tenant
  environment = local.vars.environment
  stage       = local.vars.stage
  name        = local.vars.name
  region      = local.vars.region

  tags = merge(local.tags, local.global_vars.locals.tags, local.env_vars.locals.tags, local.region_vars.locals.tags, local.service_vars.locals.tags)
}
