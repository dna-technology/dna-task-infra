locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
     env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  vars        = merge(local.global_vars.locals, local.region_vars.locals, local.env_vars.locals)

}

terraform {
  source = "git::https://github.com/cloudposse/terraform-aws-ec2-instance.git"
}

inputs = {
  enabled              = true
    disable_alarm_action = true
        attributes           = ["elastic"]
    instance_type        = "t3a.medium"
      instance_profile    = dependency.iam_profile.outputs.instance_profile

    instance_initiated_shutdown_behavior = "terminate"
      vpc_id                               = dependency.vpc.outputs.vpc_id
      subnet                               = dependency.vpc.outputs.private_subnets[0]

  security_group_rules = [
    {
      type        = "egress"
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}

dependency "cloudwatch" {
  config_path = "${local.vars.root_dir}/${local.vars.region}/cloudwatch/ec2"
}

dependency "vpc" {
  config_path = "${local.vars.root_dir}/${local.vars.region}/vpc"
}

dependency "iam_profile" {
  config_path = "${local.vars.root_dir}/${local.vars.region}/iam"
}