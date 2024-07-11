locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("globals.hcl"))
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  vars        = merge(local.global_vars.locals, local.env_vars.locals)

}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-rds-aurora.git"
}

inputs = {
  name        = "${local.vars.namespace}-${local.vars.environment}-${local.vars.stage}-default-db"

  create_security_group = false
  create_db_subnet_group = false

  engine         = "aurora-postgresql"
  engine_version = "14.5"
  instance_class = "db.r6g.large"
  instances = {
    one = {}
    2 = {
      instance_class = "db.r6g.2xlarge"
    }
  }

  vpc_id               = dependency.vpc.outputs.vpc_id
  db_subnet_group_name = dependency.vpc.outputs.database_subnets
  security_group_rules = {
    ex1_ingress = {
      source_security_group_id = dependency.vpc.outputs.default_security_group_id
    }
  }

  storage_encrypted   = false
  apply_immediately   = true

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Environment = "Results of Elastic queries"
  }
}

dependency "vpc" {
  config_path = "${local.vars.root_dir}/${local.vars.region}/vpc"
}