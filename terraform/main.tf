locals {
  aws_account_id = "123456789012"
  domain_main    = "example.com"
}

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc?ref=v5.8.0"

  name = "${var.namespace}-${var.environment}-vpc"
  azs             = lookup(var.az_list_map, var.environment)

  cidr = "10.10.0.0/20"
  private_subnets = ["10.10.0.0/23", "10.10.0.0/23"]
  public_subnets = ["10.10.8.0/23", "10.10.9.0/23"]
  database_subnets = ["10.10.16.0/24", "10.10.17.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_ipv6 = false

  enable_flow_log                      = false
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = {
    Namespace   = var.namespace
    Environment = var.environment
  }
}
