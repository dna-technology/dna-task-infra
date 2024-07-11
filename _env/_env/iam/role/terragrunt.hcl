locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  vars        = merge(local.global_vars.locals, local.env_vars.locals)

  name             = regex("[a-zA-Z0-9\\-\\_]+$", get_terragrunt_dir())
}

terraform {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git"
}

inputs = {
  name        = "${local.vars.namespace}-${local.vars.environment}-${local.vars.stage}-default-profile"
  instance_profile_enabled = true

  policy_description = format("Policy for %s user in region %s", local.vars.stage, local.vars.region)
  role_description   = format("Instance profile for %s user in region %s", local.vars.stage, local.vars.region)

  principals = {
    AWS = ["arn:aws:iam::123456789012:role/workers"]
  }

  policy_documents = [
    <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
  ]
}